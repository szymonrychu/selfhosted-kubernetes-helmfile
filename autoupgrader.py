#!/usr/bin/env python3
from ruamel.yaml import round_trip_load
import logging

from lib.helmfile import Helmfile

FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(format=FORMAT, level=logging.INFO)


def load_helmfiles():
    with open('helmfile.yaml', 'r') as f:
        main_helmfile = round_trip_load(f.read())
        for helmfile_raw in main_helmfile['helmfiles']:
            yield Helmfile(helmfile_raw['path'])

def _main():
    repo_cache = []
    for helmfile in load_helmfiles():
        repo_cache = helmfile.upgrade_all_releases(repo_cache)
        helmfile.write()

if __name__ == '__main__':
    _main()