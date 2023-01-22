import requests
import string
import logging
from ruamel.yaml import round_trip_load, round_trip_dump
from typing import List
from enum import Enum

from .version import Version

class UpgradeType(Enum):
    MAJOR_MINOR_PATCH = 'all'
    MINOR_PATCH_ONLY = 'minor'
    PATCH_ONLY = 'patch'

    @classmethod
    def values(self):
        return [member.value for member in UpgradeType]


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
    
    def get_latest_chart_version(self, chart: str, current_version: Version, upgrade_type: UpgradeType) -> str:
        chart_versions = {}

        for chart_name, releases_list in self._load_index()['entries'].items():
            if chart_name not in chart_versions.keys():
                chart_versions[chart_name] = []
            for release in releases_list:
                version = Version(release['version'])
                if version.is_stable:
                    chart_versions[chart_name].append(version)
        
        sorted_versions = sorted(chart_versions[chart])
        result = None

        if not sorted_versions:
            logging.warning(f"Error handling '{chart}-{current_version}', can't find suitable upgrade version!")
        elif upgrade_type == UpgradeType.PATCH_ONLY:
            for  _v in sorted_versions:
                if _v.major == current_version.major and _v.minor == current_version.minor:
                    result = _v
        
        elif upgrade_type == UpgradeType.MINOR_PATCH_ONLY:
            for  _v in sorted_versions:
                if _v.major == current_version.major:
                    result = _v
        
        elif sorted_versions[-1] > current_version:
            result = sorted_versions[-1]

        return result or current_version


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
        self._version = version

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

    def upgrade_release(self, release_name: str, new_version: str) -> bool:
        for helm_release in self.get_releases():
            if helm_release.name == release_name:
                logging.info(f"Uprading of '{helm_release.repo_name}/{helm_release.chart}' '{new_version}'")
                helm_release.update_version(new_version)
                return True
        logging.info(f"Release named '{release_name}' not found!")
        return False

    def upgrade_all_releases(self, repository_cache: List[HelmRepository] = [], upgrade_type: UpgradeType = UpgradeType.MAJOR_MINOR_PATCH) -> List[HelmRepository]:
        repository_cache = self._merge_repos_cache(repository_cache)
        for helm_repository in repository_cache:
            for helm_release in self.get_releases():
                if helm_release.repo_name == helm_repository.name:
                    new_version = helm_repository.get_latest_chart_version(helm_release.chart, helm_release.version, upgrade_type)
                    if new_version != helm_release.version:
                        logging.info(f"Found new version of '{helm_release.repo_name}/{helm_release.chart}' '{new_version}'")
                        helm_release.update_version(new_version)
                    else:
                        logging.info(f"Release '{helm_release.repo_name}/{helm_release.chart}' up to date with version '{helm_release.version}'")
