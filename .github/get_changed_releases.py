#!/usr/bin/env python3

import json
import sys
import yaml
import os

def get_helmfile_releases(helmfile_fpath, changed_f_path=None):
    helmfile = {}
    with open(helmfile_fpath, 'r') as helmfile_fd:
        helmfile = yaml.safe_load(helmfile_fd)
    if not helmfile:
        raise ValueError('Helmfile not loaded!')
    
    helmfile_dir = os.path.dirname(helmfile_fpath)
    
    result = []
    for release in helmfile['releases']:
        release_subpath = os.path.join(helmfile_dir, 'values', release['name'])
        if not changed_f_path or release_subpath in changed_f_path:
            label = f"application={release['labels']['application']}"
            if label not in result:
                result.append(label)
    
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