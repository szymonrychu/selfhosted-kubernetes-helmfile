#!/usr/bin/env python3
from ruamel.yaml import round_trip_load
from requests.exceptions import ConnectionError
import logging
import argparse
import sys

from lib.helmfile import Helmfile


def load_helmfiles():
    with open('helmfile.yaml', 'r') as f:
        main_helmfile = round_trip_load(f.read())
        for helmfile_raw in main_helmfile['helmfiles']:
            yield Helmfile(helmfile_raw['path'])

def get_args() -> dict:
    parser = argparse.ArgumentParser()
    parser.add_argument('--debug', help='If enabled won\'t do any updates to files', action='store_true', required=False, default=False)
    return vars(parser.parse_args(sys.argv[1:]))


def main():
    args = get_args()
    repo_cache = []
    for helmfile in load_helmfiles():
        try:
            repo_cache = helmfile.upgrade_all_releases(repo_cache)
            if not args['debug']:
                helmfile.write()
        except ConnectionError as e:
            logging.error(str(e))


if __name__ == '__main__':
    main()
