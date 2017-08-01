import os
import time
import psutil
from _base import Application
from _base import consoleLogger
from _base import set_env
from _base import del_env

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

    def undeploy(self, async=False):
        return super(Apache2, self).undeploy(async)


class Django(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Django, self).__init__("django", deploy_config, deploy_platform)

    def deploy(self, async=False):
        set_env('WEBTIER_DJANGO_REVISION', '1109c7eecf23584fd3520bd7257f8b1268b78c3b')
        set_env('WEBTIER_DJANGO_WORKERS', self.deploy_config['workers'])
        return super(Django, self).deploy(async)

    def start(self, async=False):
        return super(Django, self).start(async)

    def undeploy(self, async=False):
        os.system('rm -rf django-workload')
        return super(Django, self).undeploy(async)

class Django_docker(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Django_docker, self).__init__("django_docker", deploy_config, deploy_platform)

    def deploy(self, async=False):
        return super(Django_docker, self).deploy(async)

    def start(self, async=False):
        return super(Django_docker, self).start(async)

    def undeploy(self, async=False):
        return super(Django_docker, self).undeploy(async)

class Wordpress(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Wordpress, self).__init__("wordpress", deploy_config, deploy_platform)

    def deploy(self, async=False):
        set_env('WEBTIER_OSS_PERFROMANCE_REV', '9b1a334c4fd0974cdb52dfb5a0862f77e5d2a9c0')
        set_env('WEBTIER_WORDPRESS_WORKERS', self.deploy_config['workers'])
        return super(Wordpress, self).deploy(async)

    def start(self, async=False):
        return super(Wordpress, self).start(async)

    def stop(self, async=False):
        return super(Wordpress, self).stop(async)

    def undeploy(self, async=False):
        os.system('rm -rf oss-performance')
        return super(Wordpress, self).undeploy(async)



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
                consoleLogger("Port value not set in the json file for "+self.deploy_config['name'])
            outfile.writelines("MEMORY:" + str(self.deploy_config['minrequiredMemory']))
            outfile.write("LISTEN:" +  self.deploy_config['ip'])
            outfile.write("PORT:" + str(self.deploy_config['port']))
            outfile.write("USER:" + self.deploy_config['user'])
        if usage.free <= self.deploy_config['minrequiredMemory']:
            mem_size = usage.free/_MB
            consoleLogger(str(mem_size)+"Mb not enough free memmory space for memcached. Minimum required 5Gb")
            exit();
        return super(Memcached, self).deploy(async)

    def undeploy(self, async=False):
        return super(Memcached, self).undeploy(async)

class Memcached_docker(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Memcached_docker, self).__init__("memcached_docker", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(Memcached_docker, self).start(async)

    def deploy(self, async=False):
        return super(Memcached_docker, self).deploy(async)

    def undeploy(self, async=False):
        return super(Memcached_docker, self).undeploy(async)

###############################################################################
# Databases
###############################################################################
class Cassandra(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Cassandra, self).__init__("cassandra", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(Cassandra, self).start(async)

    def undeploy(self, async=False):
        return super(Cassandra, self).undeploy(async)

class Cassandra_docker(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Cassandra_docker, self).__init__("cassandra_docker", deploy_config, deploy_platform)

    def deploy(self, async=False):
	return super(Cassandra_docker, self).deploy(async)

    def start(self, async=False):
        return super(Cassandra_docker, self).start(async)

    def stop(self, async=False):
	return super(Cassandra_docker, self).stop(async)

    def undeploy(self, async=False):
        return super(Cassandra_docker, self).undeploy(async)

class MariaDb(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MariaDb, self).__init__("mariadb", deploy_config, deploy_platform)

    def start(self, async=False):
        return super(MariaDb, self).start(async)

    def undeploy(self, async=False):
        return super(MariaDb, self).undeploy(async)


###############################################################################
# Performance measurements
###############################################################################
class Perf(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Perf, self).__init__("perf", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('PERF_FILENAME', gen_perf_filename())
        return super(Perf, self).start(async)

    def undeploy(self, async=False):
        return super(Perf, self).undeploy(async)


class Sar(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Sar, self).__init__("sar", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('SAR_FILENAME', gen_perf_filename())
        return super(Sar, self).start(async)

    def undeploy(self, async=False):
        return super(Sar, self).undeploy(async)


class Statsd(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(Statsd, self).__init__("statsd", deploy_config, deploy_platform)

    def start(self, async=False):
        set_env('SAR_FILENAME', gen_perf_filename())
        return super(Statsd, self).start(async)

    def undeploy(self, async=False):
        return super(Statsd, self).undeploy(async)


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

    def undeploy(self, async=False):
        return super(ApacheBenchmark, self).undeploy(async)


class Siege(Application):
    def __init__(self, deploy_config, deploy_platform):
        self.benchmark_config = {}
        super(Siege, self).__init__("siege", deploy_config, deploy_platform)

    def set_benchmark_config(self, benchmark_config):
        self.benchmark_config = benchmark_config

    def deploy(self, async=False):
        set_env('WEBTIER_DJANGO_REVISION', '1109c7eecf23584fd3520bd7257f8b1268b78c3b')
        return super(Siege, self).deploy(async)

    def start(self, async=False):
        if 'customrun' in self.benchmark_config:
            set_env('WEBTIER_SIEGE_RUNMODE', self.benchmark_config['customrun'])
            consoleLogger("Be aware that the siege will run in a custom way decided by the user in the json file")
        set_env('WEBTIER_SIEGE_WORKERS', self.benchmark_config['workers'])
        return super(Siege, self).start(async)

    def undeploy(self, async=False ):
        if os.path.isfile('siege-2.78.tar.gz'):
            os.system('rm -rf siege-2.78.tar.gz')
            os.system('rm -rf siege-2.78')
        return super(Siege, self).undeploy(async)

class Siege_docker(Application):
    def __init__(self, deploy_config, deploy_platform):
        self.benchmark_config = {}
        super(Siege_docker, self).__init__("siege_docker", deploy_config, deploy_platform)

    def set_benchmark_config(self, benchmark_config):
	self.benchmark_config = benchmark_config

    def deploy(self, async=False):
        return super(Siege_docker, self).deploy(async)

    def start(self, async=False):
        return super(Siege_docker, self).start(async)

    def stop(self, async=False):
	return super(Siege_docker, self).stop(async)

    def undeploy(self, async=False ):
        return super(Siege_docker, self).undeploy(async)
