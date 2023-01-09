#!/usr/bin/env python3
from ruamel.yaml import round_trip_load
import logging
import argparse
import sys

from lib.helmfile import Helmfile

FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(format=FORMAT, level=logging.INFO)

def _main(helmfile_path, release_name, release_version):
    helmfile = None

    with open(helmfile_path, 'r') as f:
        helmfile = Helmfile(helmfile_path)
    
    if not helmfile:
        logging.error(f"Couldn't load helmfile on path '{helmfile_path}'!")
        sys.exit(1)
    
    release_upgraded = helmfile.upgrade_release(release_name, release_version)
    if not release_upgraded:
        sys.exit(2)
    
    helmfile.write()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("--helmfile-path", '-p', help='Path to helmfile to upgrade version')
    parser.add_argument("--release-name", '-n', help='Name of the release to upgrade')
    parser.add_argument("--release-version", '-v', help='Version of the release to upgrade')

    args = parser.parse_args()

    _main(args.helmfile_path, args.release_name, args.release_version)