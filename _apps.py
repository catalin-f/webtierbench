import os
import time
import psutil
from _base import Application
from _base import consoleLogger
from _base import set_env

_MB = (1024*1024)
port_increment = 0

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
        set_env('WEBTIER_DJANGO_WORKERS', self.deploy_config['workers'])
        return super(Django, self).deploy(async)


###############################################################################
# Caching
###############################################################################
class Memcached(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Memcached, self).__init__("memcached", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(Memcached, self).start(async)

    def deploy(self, async=False):
        global port_increment
        usage = psutil.virtual_memory()
        if os.path.exists("/etc/memcached.conf"):
            os.rename("/etc/memcached.conf","/etc/memcached.conf.old")
        with open("/etc/memcached.conf", "w") as outfile:
            if 'user' not in self.deploy_config:
                self.deploy_config['user'] = "memcache"
            if 'port' not in self.deploy_config:
                self.deploy_config['port'] = 11811 + port_increment
                port_increment = port_increment + 1
                consoleLogger("Port value not set in the json file for"+self.deploy_config['name'])
            outfile.writelines("MEMORY:" + str(self.deploy_config['memsize']))
            outfile.write("LISTEN:" +  self.deploy_config['ip'])
            outfile.write("PORT:" + str(self.deploy_config['port']))
            outfile.write("USER:" + self.deploy_config['user'])
        if usage.free <= self.deploy_config['memsize']:
            mem_size = usage.free/_MB
            consoleLogger(str(mem_size)+"Mb not enough free memmory space for memcached. Minimum required 5Gb")
            exit();

        return super(Memcached, self).deploy(async)


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