#!/usr/bin/env python3

import requests
import string
from ruamel.yaml import round_trip_load, round_trip_dump
from typing import List, Generator
import logging

FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(format=FORMAT, level=logging.INFO)

class Version():

    def __init__(self, raw: str):

        if raw.startswith('v'):
            raw = raw[1:]
        self._suffix = ''
        if '-' in raw:
            raw_splitted = raw.split('-')
            main, self._suffix = raw_splitted[0], '-'.join(raw_splitted[1:])
        else:
            main = raw
        main_splitted = main.split('.')
        self._major = main_splitted[0]
        self._minor = main_splitted[1]
        try:
            self._patch = main_splitted[2]
        except IndexError:
            self._patch = None
    
    def __str__(self):
        main_splitted = [self._major, self._minor, self._patch]
        main = '.'.join([p for p in main_splitted if p])
        if self._suffix:
            return '-'.join([main, self._suffix])
        else:
            return main
    
    @property
    def major(self) -> int:
        return int(self._major)
    
    @property
    def minor(self) -> int:
        return int(self._minor)
    
    @property
    def patch(self) -> int:
        return int(self._patch)
    
    @property
    def suffix(self) -> str:
        return self._suffix
    
    @property
    def is_stable(self) -> bool:
        return self.suffix == ''

    def __eq__(self, other):
        return self.major == other.major and self.minor == other.minor and self.patch == other.patch and self.suffix == other.suffix

    def __lt__(self, other):
        if self.major < other.major:
            return True
        elif self.major == other.major:
            if self.minor < other.minor:
                return True
            elif self.minor == other.minor and self.patch < other.patch:
                return True
        return False

    def __le__(self, other):
        return self.__eq__(other) or self.__lt__(other)

    def __ne__(self, other):
        return not self.__eq__(other)
    
    def __gt__(self, other):
        return not self.__le__(other)
    
    def __ge__(self, other):
        return self.__eq__(other) or self.__gt__(other)

class HelmRepository():

    def __init__(self, name: str, url: str):
        self._name = name
        self._url = url
        if self._url.endswith('/'):
            self._url = self._url[:-1]
        self._repo_index = None

    @property
    def name(self) -> str:
        return self._name

    @property
    def url(self) -> str:
        return self._url
    
    def _load_index(self) -> dict:
        if not self._repo_index:
            index_url = '/'.join([self.url, 'index.yaml'])
            logging.debug(f"Downloading index from '{self.name}' and url '{index_url}'")
            resp = requests.get(index_url)
            if resp.status_code == 200:
                raw_index_yaml = ''.join([x if x in string.printable else '' for x in resp.text])
                self._repo_index = round_trip_load(raw_index_yaml)
            else:
                logging.error(f"Couldn't download index- code was '{resp.status_code}'")
        return self._repo_index
    
    def get_latest_chart_version(self, chart: str) -> str:
        chart_versions = {}
        for chart_name, releases_list in self._load_index()['entries'].items():
            if chart_name not in chart_versions.keys():
                chart_versions[chart_name] = []
            for release in releases_list:
                version = Version(release['version'])
                if version.is_stable:
                    chart_versions[chart_name].append(version)
        return sorted(chart_versions[chart])[-1]


class HelmRelease():
    
    def __init__(self, name: str, version: str, chart: str, repo_name: str):
        self._name = name
        self._version = Version(version)
        self._chart = chart
        self._repo_name = repo_name

    @property
    def name(self) -> str:
        return self._name

    @property
    def version(self) -> str:
        return self._version
    
    def update_version(self, version: Version):
        self._version = str(version)

    @property
    def chart(self) -> str:
        return self._chart

    @property
    def repo_name(self) -> str:
        return self._repo_name

class Helmfile():

    def __init__(self, path):
        self._path = path
        self._data = None
        self.__releases = []
        self.__repositories = []
        with open(self._path, 'r') as f:
            logging.info(f"Loading '{self._path}'")
            self._data = round_trip_load(f.read())

    def write(self):
        if self._data:
            for release in self.get_releases():
                for raw_release in self._data['releases']:
                    if release.name == raw_release['name']:
                        raw_release['version'] = str(release.version)
            with open(self._path, 'w') as f:
                f.write(round_trip_dump(self._data))

    @property
    def path(self) -> str:
        return self._path
        
    def get_releases(self) -> List[HelmRelease]:
        if not self.__releases:
            for raw_release in self._data['releases']:
                self.__releases.append(HelmRelease(
                    raw_release['name'],
                    raw_release['version'],
                    raw_release['chart'].split('/')[1],
                    raw_release['chart'].split('/')[0]
                ))
        return self.__releases

    def get_repositories(self) -> List[HelmRepository]:
        if not self.__repositories:
            for raw_repository in self._data['repositories']:
                self.__repositories.append(HelmRepository(
                    raw_repository['name'],
                    raw_repository['url']
                ))
        return self.__repositories

    def _merge_repos_cache(self, repository_cache: List[HelmRepository] = []) -> List[HelmRepository]:
        if not repository_cache:
            return self.get_repositories()
        result = []
        for repo in self.get_repositories():
            tmp_repo = repo
            for cached_repo in repository_cache:
                if repo.name == cached_repo.name and repo.url == cached_repo.url:
                    tmp_repo = cached_repo
                    break
            result.append(tmp_repo)
        return result

    def upgrade_all_releases(self, repository_cache: List[HelmRepository] = []) -> List[HelmRepository]:
        repository_cache = self._merge_repos_cache(repository_cache)
        for helm_repository in repository_cache:
            for helm_release in self.get_releases():
                if helm_release.repo_name == helm_repository.name:
                    new_version = helm_repository.get_latest_chart_version(helm_release.chart)
                    if new_version != helm_release.version:
                        logging.info(f"Found new version of '{helm_release.repo_name}/{helm_release.chart}' '{new_version}'")
                        helm_release.update_version(new_version)
                    else:
                        logging.info(f"Release '{helm_release.repo_name}/{helm_release.chart}' up to date with version '{helm_release.version}'")

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