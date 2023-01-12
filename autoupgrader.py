#!/usr/bin/env python3
from ruamel.yaml import round_trip_load
import logging
import argparse

from lib.helmfile import Helmfile, UpgradeType

FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(format=FORMAT, level=logging.INFO)

parser = argparse.ArgumentParser()
parser.add_argument(
    '--dry-run',
    action='store_true',
    default=False,
    help='Dry run flag- if set, will pull possible updates, but won\'t edit files. Default=False'
)
parser.add_argument(
    "--upgrade-type",
    choices=UpgradeType.values(),
    type=str,
    help="URL to source Gitlab.",
    default=UpgradeType.MAJOR_MINOR_PATCH.value
)
args = parser.parse_args()

def load_helmfiles():
    with open('helmfile.yaml', 'r') as f:
        main_helmfile = round_trip_load(f.read())
        for helmfile_raw in main_helmfile['helmfiles']:
            yield Helmfile(helmfile_raw['path'])

def _main():
    repo_cache = []
    for helmfile in load_helmfiles():
        repo_cache = helmfile.upgrade_all_releases(repo_cache, UpgradeType(args.upgrade_type))
        if not args.dry_run:
            helmfile.write()

if __name__ == '__main__':
    _main()