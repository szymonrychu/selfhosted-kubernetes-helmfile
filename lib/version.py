class Version():

    def __init__(self, version: str):
        raw = str(version)
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
