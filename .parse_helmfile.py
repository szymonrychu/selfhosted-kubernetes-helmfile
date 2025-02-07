#!/usr/bin/env python3

from typing import List, Dict, ForwardRef
from pydantic import BaseModel, root_validator
import yaml
import os
import logging
import jinja2

_environment_key = 'LOG_LEVEL'
_environment_value_to_level = {
    'DEBUG': logging.DEBUG,
    'INFO':  logging.INFO,
    'WARN':  logging.WARN,
    'ERROR': logging.ERROR,
    'FATAL': logging.FATAL
}

_log_level = _environment_value_to_level[os.environ.get(_environment_key, 'INFO')]
logging.basicConfig(level=_log_level, format='[%(asctime)s %(filename)s->%(funcName)s():%(lineno)s] %(levelname)s: %(message)s')
_log = logging.getLogger(__name__)

Release = ForwardRef('Release')

class File(BaseModel):
    path: str = None

class SubHelmfile(File):
    pass

class ReleaseHelmfile(BaseModel):
    name: str
    namespace: str
    chart: str
    version: str = None
    labels: Dict[str,str]
    needs: List[str] = []
    source_path: str = None

class Helmfile(File):
    helmfiles: List[SubHelmfile] = []
    releases: List[ReleaseHelmfile] = []

class Release(BaseModel):
    namespace_name: str
    labels: Dict[str,str] = {}
    needed_by: List[Release] = []
    needs: List[Release] = []
    changed_files: List[str] = []

    @staticmethod
    def from_helmfile_release(hr: ReleaseHelmfile) -> Release:
        r = Release(namespace_name = f"{hr.namespace}/{hr.name}")
        r.labels = hr.labels
        r.needs = [
            Release(namespace_name = hr_need) for hr_need in hr.needs
        ]
        if hr.source_path:
            r.changed_files.append(hr.source_path)
            _helmfile_root = os.path.dirname(hr.source_path)
            _values_path = os.path.join(_helmfile_root, 'values', hr.name)
            r.changed_files.append(_values_path + '/**')
        return r


class Stage(BaseModel):
    releases: List[Release] = []

Release.update_forward_refs()


class HelmfileReleaseParser:

    def __init__(self, root_helmfile_path:str = 'helmfile.yaml'):
        _log.info(f"Loading root helmfile from {root_helmfile_path}")
        self._main_helmfile = self._parse_helmfile(root_helmfile_path)
        for subhelmfile in self._main_helmfile.helmfiles:
            _log.info(f"Loading sub-helmfile from {subhelmfile.path}")
            releases = self._parse_helmfile(subhelmfile.path).releases
            for release in releases:
                release.source_path = subhelmfile.path
            self._main_helmfile.releases.extend(releases)
        self._main_helmfile.helmfiles = []
        self._stages = []
        
    def _parse_helmfile(self, path):
        _data = None
        with open(path) as f:
            _data = yaml.safe_load(f.read())
        return Helmfile(**_data) if _data else None
    
    def _remove_release_from_stage(self, stage:Stage, release_namespace_name: str) -> bool:
        for idx in range(len(stage.releases)):
            _release_namespace_name = stage.releases[idx].namespace_name
            if _release_namespace_name == release_namespace_name:
                del stage.releases[idx]
                return True
        return False
    
    def _add_stage_if_needed(self, next_stage:Stage = None) -> Stage:
        if not next_stage:
            return Stage()
        else:
            return next_stage

    def get_stages(self):
        _stages = []
        _all_releases = {
            r.namespace_name: r for r in [
                Release.from_helmfile_release(hr) for hr in self._main_helmfile.releases
            ]
        }
        current_stage = Stage(releases = list(_all_releases.values()))
        while current_stage:
            next_stage = None
            to_be_deleted_releases = []
            for release in current_stage.releases:
                for need in release.needs:
                    next_stage = self._add_stage_if_needed(next_stage)
                    _need = _all_releases[need.namespace_name]
                    if _need not in next_stage.releases:
                        next_stage.releases.append(_need)
                    to_be_deleted_releases.append(_need.namespace_name)
        
            for to_be_delete_release in to_be_deleted_releases:
                self._remove_release_from_stage(current_stage, to_be_delete_release)
            
            _stages.append(current_stage)
            current_stage = next_stage

        _stages = list(reversed(_stages))
        return _stages


def main():
    _helmfile_path = os.environ.get('ROOT_HELMFILE_PATH', 'helmfile.yaml')
    _template_path = os.environ.get('TEMPLATE_PATH', '.sub.gitlab-ci.yml.j2')
    _helmfile_command = os.environ.get('HELMFILE_COMMAND', 'apply')

    result = []
    for idx, stage in enumerate(HelmfileReleaseParser(_helmfile_path).get_stages()):
        releases = []
        for release in stage.releases:
            namespace, name = release.namespace_name.split('/')
            releases.append({
                'name': name,
                'namespace': namespace,
                'labels': release.labels,
                'changed_files': release.changed_files
            })
        result.append({
            'name': f"stage_{idx}",
            'releases': releases
        })

    


    print(yaml.dump({
        'stages': result
    }))


    templateLoader = jinja2.FileSystemLoader(searchpath="./")
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(_template_path)
    output_text = template.render(stages=result, helmfile_command=_helmfile_command)  # this is where to put args to the template renderer

    print(output_text)
    # with open(OUTPUT_FILE, 'w') as f:
    #     f.write(output_text)


if __name__ == '__main__':
    main()
