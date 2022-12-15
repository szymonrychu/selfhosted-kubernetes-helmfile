import sys
import logging
import os

def _get_logger(logger_name: str = 'main') -> logging.Logger:
    _env2logging = {
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO,
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR
    }
    _logging_level = logging.INFO
    try:
        _logging_level = os.environ.get('LOG_LEVEL', 'INFO')
    except KeyError:
        pass
    logging.basicConfig(level=_logging_level, stream=sys.stderr)
    _logger = logging.getLogger(logger_name)
    _logger.setLevel(_logging_level)
    return _logger


log = _get_logger()
