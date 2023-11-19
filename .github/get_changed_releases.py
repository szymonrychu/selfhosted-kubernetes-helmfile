#!/usr/bin/env python3

import json
import sys
import yaml
import os

def read_main_helmfile_paths():
    this_path = os.path.abspath(__file__)
    repo_root = os.path.dirname(os.path.dirname(this_path))
    helmfile_fpath = os.path.join(repo_root, 'helmfile.yaml')
    helmfile = {}
    with open(helmfile_fpath, 'r') as helmfile_fd:
        helmfile = yaml.safe_load(helmfile_fd)
    if not helmfile:
        raise ValueError('Helmfile not loaded!')
    
    enabled_paths = []
    for sub_helmfile in helmfile['helmfiles']:
        sub_helmfile_path = sub_helmfile['path']
        sub_path = os.path.dirname(sub_helmfile_path)
        enabled_paths.append(sub_path)

    return enabled_paths


def get_helmfile_releases(helmfile_fpath, changed_f_path=None):
    helmfile = {}
    with open(helmfile_fpath, 'r') as helmfile_fd:
        helmfile = yaml.safe_load(helmfile_fd)
    if not helmfile:
        raise ValueError('Helmfile not loaded!')
    
    helmfile_dir = os.path.dirname(helmfile_fpath)
    
    if helmfile_dir not in read_main_helmfile_paths():
        return []
    
    result = []
    for release in helmfile['releases']:
        release_subpath = os.path.join(helmfile_dir, 'values', release['name'])
        if not changed_f_path or release_subpath in changed_f_path:
            try:
                label = f"application={release['labels']['application']}"
                if label not in result:
                    result.append(label)
            except KeyError as _key_error:
                print(f"Missing 'application' label for release:{release['name']} in {helmfile_fpath}", file=sys.stderr)
    return result
        


def main():
    json_changed_files = sys.argv[1]
    changed_files = json.loads(json_changed_files)


    result = []
    for f in changed_files:
        if f.endswith('helmfile.yaml'):
            result.extend(get_helmfile_releases(f))
        else:
            helmfile_root = os.path.sep.join(f.split(os.path.sep)[:2])
            helmfile_path = os.path.join(helmfile_root, 'helmfile.yaml')
            for path in get_helmfile_releases(helmfile_path, f):
                if path not in result:
                    result.append(path)


    changed_releases = json.dumps(result)

    print(f"changed_releases={changed_releases}")
    print(f"changed_releases={changed_releases}", file=sys.stderr)

if __name__ == '__main__':
    main()