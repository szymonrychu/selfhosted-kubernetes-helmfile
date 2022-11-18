from enum import Enum
import requests
import string
from ruamel.yaml import round_trip_load, round_trip_dump
from ruamel.yaml.comments import CommentedMap
from typing import List, Optional
from lib.logger import log

from .version import Version

class HelmReleaseKeepUpgrade(Enum):
    MAJOR = 'major'
    MINOR = 'minor'
    PATCH = 'patch'
    NOTHING = 'nothing'

    @staticmethod
    def members():
        return [e.value for e in HelmReleaseKeepUpgrade]
    
    def to_version_str(self, version: Version):
        if self.value == HelmReleaseKeepUpgrade.PATCH.value:
            return str(version)
        _result = []
        if self.value in [HelmReleaseKeepUpgrade.MAJOR.value, HelmReleaseKeepUpgrade.MINOR.value]:
            _result.append(version.major)
        if self.value == HelmReleaseKeepUpgrade.MINOR.value:
            _result.append(version.minor)
        return '.'.join([str(i) for i in _result]) if _result else None


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
            log.debug(f"Downloading index from '{self.name}' and url '{index_url}'")
            resp = requests.get(index_url)
            if resp.status_code == 200:
                raw_index_yaml = ''.join([x if x in string.printable else '' for x in resp.text])
                self._repo_index = round_trip_load(raw_index_yaml)
            else:
                log.error(f"Couldn't download index- code was '{resp.status_code}'")
        return self._repo_index
    
    def get_latest_chart_version(self, chart: str, constraint: str = None) -> str:
        chart_versions = {}
        for chart_name, releases_list in self._load_index()['entries'].items():
            if chart_name not in chart_versions.keys():
                chart_versions[chart_name] = []
            for release in releases_list:
                version = Version(release['version'])
                if version.is_stable:
                    chart_versions[chart_name].append(version)
        
        versions_newest_to_latest = list(reversed(sorted(chart_versions[chart])))
        next_upgrade_version = None
        if not constraint:
            next_upgrade_version = versions_newest_to_latest[0]
        else:
            log.info(f"Upgrade version constraint: '{constraint}'")
            for v in versions_newest_to_latest:
                if str(v).startswith(constraint):
                    next_upgrade_version = v
        return next_upgrade_version


class HelmRelease():
    
    
    def __init__(self, release: CommentedMap):
        self.__raw_release = release

        # name: str, version: str, chart: str, repo_name: str):
        # self._name = name
        # self._version = Version(version)
        # self._chart = chart
        # self._repo_name = repo_name
        # self._comment = None

    @property
    def name(self) -> str:
        return self.__raw_release['name']

    @property
    def version(self) -> str:
        return Version(self.__raw_release['version'])
    
    def update_version(self, version: Version):
        self.__raw_release['version'] = str(version)

    @property
    def chart(self) -> str:
        return self.__raw_release['chart'].split('/')[1]

    @property
    def repo_name(self) -> str:
        return self.__raw_release['chart'].split('/')[0]

    @property
    def version_comment(self) -> Optional[str]:
        _token = self.__raw_release.ca.items.get('version')
        if _token:
            comment = _token[2].value.strip()
            return comment
        return None

    @property
    def raw(self):
        return self.__raw_release
    
    @property
    def allowed_upgrades(self):
        comment = self.version_comment.lower() if self.version_comment else ''
        while comment.startswith(' ') or comment.startswith('#'):
            comment = comment[1:]
        comment = comment.strip()
        
        if comment:
            log.info(f'Found version comment: {comment}')
        
        result = HelmReleaseKeepUpgrade.NOTHING
        for upgrade_type in HelmReleaseKeepUpgrade.members():
            if comment == f'keep: {upgrade_type}' or comment == f'keep {upgrade_type}':
                result = HelmReleaseKeepUpgrade(upgrade_type)
                break
        return result

    @property
    def allowed_upgrade_str(self):
        return self.allowed_upgrades.to_version_str(self.version)
        

class Helmfile():

    def __init__(self, path):
        self._path = path
        self._data = None
        self.__releases = []
        self.__repositories = []
        with open(self._path, 'r') as f:
            log.info(f"Loading '{self._path}'")
            self._data = round_trip_load(f.read())

    def write(self):
        if self._data:
            releases = self.get_releases()
            self._data['releases'] = []
            for release in releases:
                self._data['releases'].append(release.raw)
            print(round_trip_dump(self._data))
            # with open(self._path, 'w') as f:
            #     f.write(round_trip_dump(self._data))

    @property
    def path(self) -> str:
        return self._path
        
    def get_releases(self) -> List[HelmRelease]:
        if not self.__releases:
            for raw_release in self._data['releases']:
                self.__releases.append(HelmRelease(raw_release))
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
                log.info(f"Uprading of '{helm_release.repo_name}/{helm_release.chart}' '{new_version}'")
                helm_release.update_version(new_version)
                return True
        log.info(f"Release named '{release_name}' not found!")
        return False

    def upgrade_all_releases(self, repository_cache: List[HelmRepository] = []) -> List[HelmRepository]:
        repository_cache = self._merge_repos_cache(repository_cache)
        for helm_repository in repository_cache:
            for helm_release in self.get_releases():
                if helm_release.repo_name == helm_repository.name:
                    log.info(f"Current version of '{helm_release.repo_name}/{helm_release.chart}': '{helm_release.version}'")
                    new_version = helm_repository.get_latest_chart_version(helm_release.chart, helm_release.allowed_upgrade_str)
                    if new_version != helm_release.version:
                        log.info(f"Found new version of '{helm_release.repo_name}/{helm_release.chart}' '{new_version}'")
                        helm_release.update_version(new_version)
                    else:
                        log.info(f"Release '{helm_release.repo_name}/{helm_release.chart}' up to date with version '{helm_release.version}'")
