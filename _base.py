import socket
import os
import glob
import sys
import platform
import pickle
import subprocess
import errno
import time
import argparse
import json
from jsonschema import validate

_WEBTIER_VERSION = "1.0"
_WEBTIER_NAME = "WebTier Benchmark"
_WEBTIER_DEPLOYMENT_JSON = ".deployment.json"
_WEBTIER_RUN_JSON = ".running.json"

_ALLOWED_WORKLOADS = ['django', 'django_docker', 'wordpress', 'apache2']
_ALLOWED_CLIENTS = ['siege', 'siege_docker', 'ab']
_ALLOWED_CACHES = ['memcached', 'memcached_docker']
_ALLOWED_DBS = ['cassandra', 'cassandra_docker', 'mariadb']
_ALLOWED_PERFS = ['perf', 'statsd', 'sar']

_5Gb = 5368709120

WEBTIER_PUBLIC_INFO = "%s version %s" % (_WEBTIER_NAME, _WEBTIER_VERSION)


###############################################################################
# Common functions and classes
###############################################################################
def _RUN_GENERIC_SCRIPT(name, async=False):
    proc = subprocess.Popen(name, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if not async:
        out = proc.stdout.read()
        err = proc.stderr.read()
        return out, err
    else:
        return '', ''


def RUN_APP_SCRIPT(name, platform, script, async=False):
    # cmd = "%s/apps/%s/%s/%s" % (os.getcwd(), name, platform.distribution, script)
    cmd = "apps/%s/%s/%s" % (name, platform.distribution, script)
    return _RUN_GENERIC_SCRIPT(cmd, async)


def pickle_deployment(deployment):
    f = open('.deployment.pickle', 'w')
    pickle.dump(deployment, f)
    f.close()


def unpickle_deployment():
    f = open('.deployment.pickle')
    deployment = pickle.load(f)
    f.close
    return deployment


def set_env(key, value):
    os.environ[str(key)] = str(value)

def del_env(value):
    del os.environ[str(value)]

def get_cpu_count():
    import multiprocessing
    return multiprocessing.cpu_count()


def root_access():
    return os.geteuid() == 0

def get_path():
    set_env('WEBTIER_PATH',os.path.realpath("."))


class Platform:
    def __init__(self):
        self.distribution = ''  # ubuntu, etc
        self.version = ''       # 16.04, etc
        self.type = ''          # posix
        self.system = ''        # linux, mac, win

    def detect(self):
        os_type = os.name
        distribution = None
        version = None
        system = platform.system()
        if os_type == 'posix':
            if system == 'Linux':
                details = platform.linux_distribution()
                distribution = details[0].lower()
                version = details[1]
            if system == 'Darwin':
                details = platform.mac_ver()
                distribution = 'mac'
                version = details[0]
            if system == 'nt':
                details = platform.win32_ver()
                distribution = 'win'
                version = details[0]
        self.distribution = distribution
        self.version = version
        self.type = os_type
        self.system = system.lower()


###############################################################################
# Command line parsers
###############################################################################
def _file_exists(filename):
    if filename.strip() == '':
        raise argparse.ArgumentTypeError("Please specify an input filename")
    if os.path.exists(filename):
        return filename
    raise argparse.ArgumentTypeError("Please use a valid filename")


def parse_deploy_args():
    parser = argparse.ArgumentParser(
        description="%s - Deployment application" % WEBTIER_PUBLIC_INFO
    )
    parser.add_argument(
        '-s', '--setup',
        help='JSON file containing the benchmark deployment information',
        type=_file_exists,
        required=True
    )
    args = parser.parse_args()
    return args.setup


def parse_run_args():
    parser = argparse.ArgumentParser(
        description="%s - Benchmark run application" % WEBTIER_PUBLIC_INFO
    )
    parser.add_argument(
        '-b', '--benchmark',
        help='JSON file containing the benchmark parameters',
        type=_file_exists,
        required=True
    )
    args = parser.parse_args()
    return args.benchmark


def parse_undeploy_args():
    parser = argparse.ArgumentParser(
        description="%s - Undeployment application" % WEBTIER_PUBLIC_INFO
    )
    parser.parse_args()
    pass


###############################################################################
# JSON input file parse and validate
###############################################################################
_deploySchema = {
    'type': 'object',
    'properties': {
        'workload': {
            'type': 'object',
            'properties': {
                'name': {'type': 'string', 'enum': _ALLOWED_WORKLOADS},
                'workers': {'type': 'integer', 'minimum': 1}
            },
            'required': ['name']
        },
        'proxy': {'type': 'string'},
        'master': {'type': 'string'},
        'slave': {
            'type': 'array',
            'items': {
                'type': 'string'
            }
        },
        'client': {
            'type': 'object',
            'properties': {
                'name': {'type': 'string', 'enum': _ALLOWED_CLIENTS},
                'ip': {'type': 'string'}
            },
            'required': ['name']
        },
        'cache': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string', 'enum': _ALLOWED_CACHES},
                    'ip': {'type': 'string'},
                    'port': {'type': 'integer', 'minimum': 1, 'maximum': 65535},
                    'minrequiredMemory': {'type': 'integer'},
                    'user': {'type': 'string'}
                },
                'required': ['name']
            },
            "minItems": 0
        },
        'db': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string', 'enum': _ALLOWED_DBS},
                    'ip': {'type': 'string'},
                    'port': {'type': 'integer', 'minimum': 1, 'maximum': 65535}
                },
                'required': ['name']
            },
            "minItems": 0
        },
        'perf': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string', 'enum': _ALLOWED_PERFS},
                },
                'required': ['name']
            },
            'minItems': 0
        }

    },
    'required': ['workload', 'client']
}

_runSchema_general = {
    'type': 'object',
    'properties': {
        'scenario': {'type': 'string', 'enum': ['file', 'endpoint']},
    },
    'required': ['scenario']
}

_runSchema_file = {
    'type': 'object',
    'properties': {
        'customrun': {'type': 'boolean'},
        'workers': {'type': 'integer', 'minimum': 1},
        'duration': {'type': 'number', 'minimum': 1},
        'filename': {'type': 'string'}
    },
    'required': ['duration', 'filename']
}

_runSchema_endpoint = {
    'type': 'object',
    'properties': {
        'customrun': {'type': 'boolean'},
        'workers': {'type': 'integer', 'minimum': 1},
        'duration': {'type': 'number', 'minimum': 1},
        'endpoint': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'address': {'type': 'string'},
                    'type': {'type': 'string', 'enum': ['GET', 'POST', 'PUT', 'DELETE']},
                    'delay': {'type': 'number'}
                },
                'required': ['address', 'type', 'delay']
            },
            'minItems': 1
        }
    },
    'required': ['duration', 'endpoint']
}


def _check_ipv4(address):
    socket.inet_aton(address)


def load_deploy_configuration(config_filename):
    with open(config_filename) as data:
        config_json = json.load(data)
    try:
        validate(config_json, _deploySchema)

        # workload > workers
        if 'workers' not in config_json['workload']:
            config_json['workload']['workers'] = get_cpu_count()

        # master
        if 'master' in config_json:
            _check_ipv4(config_json['master'])
        else:
            config_json['master'] = '127.0.0.1'
            consoleLogger("IP value not set in the json file for master, 127.0.0.1 is going to be used")

        # slave
        if 'slave' in config_json:
            for ip in config_json['slave']:
                _check_ipv4(ip)
        else:
            config_json['slave'] = ['127.0.0.1']
            consoleLogger("IP value not set in the json file for slave, 127.0.0.1 is going to be used")

        # client > ip
        if 'ip' in config_json['client']:
            _check_ipv4(config_json['client']['ip'])
        else:
            config_json['client']['ip'] = '127.0.0.1'
            consoleLogger("IP value not set in the json file for "+ str(config_json['client']['name']) + ", 127.0.0.1 is going to be used")

        # cache > ip
        if 'cache' in config_json:
            for i in xrange(len(config_json['cache'])):
                obj = config_json['cache'][i]
                if 'ip' in obj:
                    _check_ipv4(obj['ip'])
                else:
                    obj['ip'] = '127.0.0.1'
                    consoleLogger("IP value not set in the json file for "+ str(obj['name']))
                if 'minrequiredMemory' not in obj:
                    obj['minrequiredMemory'] = _5Gb

        # db > ip
        if 'db' in config_json:
            for i in xrange(len(config_json['db'])):
                obj = config_json['db'][i]
                if 'ip' in obj:
                    _check_ipv4(obj['ip'])
                else:
                    obj['ip'] = '127.0.0.1'
                    consoleLogger("IP value not set in the json file for " + obj['name'])

    except Exception as ex:
        debugLogger("Exception in load_deploy_configuration: %r" % ex)
        consoleLogger("Input JSON file is not well formed: %s" % ex.message)
        sys.exit(-1)
    return config_json


def save_deploy_configuration(config_json):
    with open(_WEBTIER_DEPLOYMENT_JSON, 'w') as outfile:
        json.dump(config_json, outfile)


def load_run_configuration(config_filename):
    with open(config_filename) as data:
        config_json = json.load(data)
    try:
        validate(config_json, _runSchema_general)
        if config_json['scenario'] == 'file':
            validate(config_json, _runSchema_file)

            # filename
            config_json["filename"] = config_json["filename"].strip()
            if config_json["filename"] == "":
                consoleLogger("JSON filename key cannot be empty")
                raise Exception("JSON filename key cannot be empty")
            if not os.path.exists(config_json["filename"]):
                consoleLogger("%s does not exist" % config_json["filename"])
                raise Exception("File does not exist")
        else:
            validate(config_json, _runSchema_endpoint)
            # TODO add other validations here
    except Exception as ex:
        debugLogger("Exception in load_deploy_configuration: %r" % ex)
        consoleLogger("Input JSON file is not well formed: %s" % ex.message)
        sys.exit(-1)
    return config_json


def save_run_configuration(config_json):
    with open(_WEBTIER_RUN_JSON, 'w') as outfile:
        json.dump(config_json, outfile)


###############################################################################
# Logging
###############################################################################
class _Logger:
    def __init__(self, filename, showTimestamp=True):
        self.filename = filename
        if not self.filename:
            self.fd = sys.stdout
        else:
            self.fd = open(filename, "a")
        self.fullMode = showTimestamp

    def _get_prefix(self):
        if self.fullMode:
            return "[%s] " % time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
        return ""

    def log(self, text):
        self.fd.write("%s%s\n" % (self._get_prefix(), text))
        self.fd.flush()


debugLogger = _Logger("webtierbench.log").log
masterLogger = _Logger("results.log", showTimestamp=False).log
consoleLogger = _Logger("", showTimestamp=False).log


###############################################################################
# Applications
###############################################################################
_ALLOWED_APPLICATIONS = _ALLOWED_CACHES + _ALLOWED_CLIENTS + _ALLOWED_DBS + \
                        _ALLOWED_PERFS + _ALLOWED_WORKLOADS
_HOST_SETUP_MARK = '.host.setup.done'
_HOST_REBOOT_REQUIRED = '/tmp/.host.reboot.required'

_OUT_SEPARATOR = ' '


class Application(object):
    def __init__(self, name, deploy_config, deploy_platform):
        if name not in _ALLOWED_APPLICATIONS:
            raise NotImplementedError("Unknown application: %s" % (name))
        self.name = name
        self.deploy_config = deploy_config
        self.deploy_platform = deploy_platform

    def deploy(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.deploy_platform, "deploy.sh", async)
        return out, err

    def undeploy(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.deploy_platform, "undeploy.sh", async)
        return out, err

    def start(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.deploy_platform, "start.sh", async)
        return out, err

    def stop(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.deploy_platform, "stop.sh", async)
        return out, err


class Deployment:
    def __init__(self, name, deploy_config, deploy_platform):
        self.deploy_platform = deploy_platform
        if self.deploy_platform.distribution == 'mac' or self.deploy_platform.distribution == 'win':
            raise NotImplementedError("This operating system is not yet supported")
        self.deploy_config = deploy_config
        self.name = name
        self.applications = []
        self.dbs = []
        self.cache = []
        self.perfs = []
        self.client = None
        self._all_apps = []

    def common_host_setup(self):
        if not os.path.isfile(_HOST_SETUP_MARK):
            consoleLogger("Configuring host(s) for benchmarking. You may be required to reboot the workstation(s) during this process")
            #check for proxy
            if 'proxy' in self.deploy_config:
                proxy = self.deploy_config['proxy'].strip()
                if proxy != '':
                    set_env("WEBTIER_HTTP_PROXY", proxy)
            out, err = _RUN_GENERIC_SCRIPT("apps/common-%s-setup.sh" % self.deploy_platform.distribution)
            with open(_HOST_SETUP_MARK, "w") as f:
                f.write('ok')
            return out, err
        return '', ''

    def reboot_required(self):
        return os.path.isfile(_HOST_REBOOT_REQUIRED)

    def deploy(self):
        outs = []
        errs = []
        for app in self._all_apps:
            consoleLogger("Deploying %s" % app.name)
            out, err = app.deploy()
            outs.append(out)
            errs.append(err)
        for app in self.perfs:
            consoleLogger("Deploying %s" % app.name)
            out, err = app.deploy()
            outs.append(out)
            errs.append(err)
        return _OUT_SEPARATOR.join(outs), _OUT_SEPARATOR.join(errs)

    def undeploy(self,undeploy_apps, undeploy_perfs):
        outs = []
        errs = []
        for app in undeploy_apps:
            consoleLogger("Undeploying %s" % app.name)
            out, err = app.undeploy()
            outs.append(out)
            errs.append(err)
        for app in undeploy_perfs:
            consoleLogger("Undeploying %s" % app.name)
            out, err = app.undeploy()
            outs.append(out)
            errs.append(err)
        return _OUT_SEPARATOR.join(outs), _OUT_SEPARATOR.join(errs)

    def start_applications(self):
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.start()
            outs.append(out)
            errs.append(err)
        return _OUT_SEPARATOR.join(outs), _OUT_SEPARATOR.join(errs)

    def start_performance_measurements(self):
        for app in self.perfs:
            app.start(async=True)
        return '', ''

    def set_benchmark_config(self, benchmark_config):
        if self.client is not None:
            self.client.set_benchmark_config(benchmark_config)

    def start_benchmark_client(self):
        if self.client is not None:
            out, err = self.client.start()
            return out, err
        return '', ''

    def stop_applications(self):
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.stop()
            outs.append(out)
            errs.append(err)
        return _OUT_SEPARATOR.join(outs), _OUT_SEPARATOR.join(errs)

    def stop_performance_measurements(self):
        for app in self.perfs:
            app.stop()
        return '', ''

    def stop_benchmark_client(self):
        if self.client is not None:
            out, err = self.client.stop()
            return out, err
        return '', ''

    def collect_performance_data(self):
        # Create results directory tree
        measurement_dirs = 'measurements/%s' % self.name
        try:
            os.makedirs(measurement_dirs)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(measurement_dirs):
                pass
            else:
                raise
        # Move files
        # TODO take into consideration the perfs content
        collect = filter(os.path.isfile, glob.glob('./*data'))
        if collect:
            for step in collect:
                os.rename(step, '%s/%s' % (measurement_dirs, step))

    #####
    def add_application(self, app):
        self.applications.append(app)
        self._all_apps.append(app)

    def add_db(self, app):
        self.dbs.append(app)
        self._all_apps.append(app)

    def add_cache(self, app):
        self.cache.append(app)
        self._all_apps.append(app)

    def add_perf(self, app):
        self.perfs.append(app)

    def set_client(self, app):
        self.client = app
        self._all_apps.append(app)
