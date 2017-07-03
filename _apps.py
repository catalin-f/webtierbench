import os
import time
from _base import Application

#TODO: add all apps here


def set_env(key, value):
    os.environ[str(key)]=str(value)


class Apache2(Application):
    def __init__(self, config, distribution, version):
        super(Apache2, self).__init__("apache2", config, distribution, version)

    def deploy(self, async=False):
        set_env('WEBTIER_APACHE_IP', self.config["ip"])
        set_env('WEBTIER_APACHE_PORT', self.config["port"])
        return super(Apache2, self).deploy(async)


class Perf(Application):
    def __init__(self, config, distribution, version):
        super(Perf, self).__init__("perf", config, distribution, version)

    def start(self, async=False):
        set_env('PERF_FILENAME', '%s.data' % time.strftime('%Y%m%d%H%M%S', time.localtime()))
        return super(Perf, self).start(async)


class ApacheBenchmark(Application):
    def __init__(self, config, distribution, version):
        super(ApacheBenchmark, self).__init__("ab", config, distribution, version)

    def start(self, async=False):
        set_env('WEBTIER_AB_WORKERS', self.config['workers'])
        set_env('WEBTIER_AB_REQUESTS', self.config['requests'])
        set_env('WEBTIER_AB_ENDPOINT', self.config['endpoint'])
        return super(ApacheBenchmark, self).start(async)
