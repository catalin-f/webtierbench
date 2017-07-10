import os
import time
from _base import Application
from _base import set_env

#TODO: add all apps here
def gen_perf_filename():
    return '%s.data' % time.strftime('%Y%m%d%H%M%S', time.localtime())


###############################################################################
# Applications
###############################################################################
class Apache2(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Apache2, self).__init__("apache2", deploy_config, deploy_platform)

    def deploy(self, async=False):
        set_env('WEBTIER_APACHE_IP', self.deploy_config["ip"])
        set_env('WEBTIER_APACHE_PORT', self.deploy_config["port"])
        return super(Apache2, self).deploy(async)


class Django(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Django, self).__init__("django", deploy_config, deploy_platform)

    def deploy(self, async=False):
        set_env('WEBTIER_DJANGO_REVISION', '96b12d5e13a6ec2141fd7e8bd8b31f9c87630ea4')
        set_env('WEBTIER_DJANGO_WORKERS', self.deploy_config['workload']['workers'])
        return super(Django, self).deploy(async)


###############################################################################
# Caching
###############################################################################
class Memcached(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Memcached, self).__init__("memcached", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(Memcached, self).start(async)


###############################################################################
# Databases
###############################################################################
class Cassandra(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Cassandra, self).__init__("cassandra", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(Cassandra, self).start(async)


###############################################################################
# Performance measurements
###############################################################################
class Perf(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Perf, self).__init__("perf", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('PERF_FILENAME', gen_perf_filename())
        return super(Perf, self).start(async)


class Sar(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Sar, self).__init__("sar", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('SAR_FILENAME', gen_perf_filename())
        return super(Sar, self).start(async)


class Statsd(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Statsd, self).__init__("statsd", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('SAR_FILENAME', gen_perf_filename())
        return super(Statsd, self).start(async)


###############################################################################
# Benchmark clients
###############################################################################
class ApacheBenchmark(Application):
    def __init__(self, deploy_config, deploy_platform):
        self.benchmark_config = {}
        super(ApacheBenchmark, self).__init__("ab", deploy_config, deploy_platform)

    def set_benchmark_config(self, benchmark_config):
        self.benchmark_config = benchmark_config

    def start(self, async=False):
        set_env('WEBTIER_AB_WORKERS', self.benchmark_config['workers'])
        set_env('WEBTIER_AB_REQUESTS', 1000)
        set_env('WEBTIER_AB_ENDPOINT', "http://localhost:80/index.html")
        return super(ApacheBenchmark, self).start(async)


class Siege(Application):
    def __init__(self, deploy_config, deploy_platform):
        self.benchmark_config = {}
        super(Siege, self).__init__("siege", deploy_config, deploy_platform)

    def set_benchmark_config(self, benchmark_config):
        self.benchmark_config = benchmark_config

    def deploy(self, async=False):
        set_env('WEBTIER_DJANGO_REVISION', '96b12d5e13a6ec2141fd7e8bd8b31f9c87630ea4')
        return super(Siege, self).deploy(async)

    def start(self, async=False):
        return super(Siege, self).start(async)