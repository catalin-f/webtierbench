import datetime
import os
import platform
import pickle
import subprocess
import errno
import time
import argparse
import json
from pprint import pprint

WEBTIER_VERSION = "1.1"


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


def RUN_APP_SCRIPT(name, distribution, version, script, async=False):
    cmd = "apps/%s/%s/%s" % (name, distribution, script)
    return _RUN_GENERIC_SCRIPT(cmd, async)


def detect_os():
    ostype = os.name
    distribution = None
    version = None
    if ostype == 'posix':
        system = platform.system()
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
    return distribution, version


def pickle_deployment(deployment):
    f = open('.deployment.pickle', 'w')
    pickle.dump(deployment, f)
    f.close()


def unpickle_deployment():
    f = open('.deployment.pickle')
    deployment = pickle.load(f)
    f.close
    return deployment



def get_args_setup():
    '''example from https://gist.github.com/redja/9276216'''

    '''This function parses and return arguments passed in'''
    # Assign description to the help doc
    parser = argparse.ArgumentParser(
        description='Script retrieves schedules from a given server')
    # Add arguments
    parser.add_argument(
        '-s', '--setup', type=str, help='Json file for single-node configuration', required=True)


    # Array for all arguments passed to script
    args = parser.parse_args()
    # Assign args to variables
    setup = args.setup
    # Return all variable values
    return setup


def get_args_benchmark():
    '''example from https://gist.github.com/redja/9276216'''

    '''This function parses and return arguments passed in'''
    # Assign description to the help doc
    parser = argparse.ArgumentParser(
        description='Script retrieves schedules from a given server')
    # Add arguments
    parser.add_argument(
        '-b', '--benchmark', type=str, help='Json file for multi-node configuration', required=True)

    # Array for all arguments passed to script
    args = parser.parse_args()
    # Assign args to variables
    benchmark = args.benchmark
    # Return all variable values
    return benchmark



def json_parse_setup(jsonfile):
    '''This function parses a json file and returns a dictionary'''
    # doc: https://stackoverflow.com/questions/2835559/parsing-values-from-a-json-file-using-python
	
    with open(jsonfile) as data_file:
        data = json.load(data_file)
        if data["workload"] == "django" or data["workload"] == "wordpress":
            return data
        else:
            raise Exception ('\"workload\" not present in json file')
            return None



###############################################################################
# Logging
###############################################################################
class _Logger:
    def __init__(self, filename, fullMode=True):
        self.filename = filename
        self.fd = open(filename, "a")
        self.fullMode = fullMode

    def _get_prefix(self):
        if self.fullMode:
            return "[%s] " % time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
        return ""

    def log(self, text):
        self.fd.write("%s%s\n" % (self._get_prefix(), text))
        self.fd.flush()


debugLogger = _Logger("webtierbench.log").log
masterLogger = _Logger("results.log", fullMode=False).log


###############################################################################
# Applications
###############################################################################

ALLOWED_APPLICATIONS = ["apache2", "ab", "perf"]
HOST_SETUP_MARK = '.host.setup.done'
HOST_REBOOT_REQUIRED = '/tmp/.host.reboot.required'

OUT_SEPARATOR = ' '

class Application(object):
    def __init__(self, name, config, distribution, version):
        if name not in ALLOWED_APPLICATIONS:
            raise NotImplementedError("Unknown application: %s" % (name))
        self.name = name
        self.config = config
        self.distribution = distribution
        self.version = version

    def deploy(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.distribution, self.version, "deploy.sh", async)
        return out, err

    def undeploy(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.distribution, self.version, "undeploy.sh", async)
        return out, err

    def start(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.distribution, self.version, "start.sh", async)
        return out, err

    def stop(self, async=False):
        out, err = RUN_APP_SCRIPT(self.name, self.distribution, self.version, "stop.sh", async)
        return out, err


class Deployment:
    def __init__(self, name, distribution, version):
        self.distribution = distribution
        self.version = version
        if distribution == 'mac' or distribution == 'win':
            raise NotImplementedError("This operating system is not yet supported")
        self.name = name
        self.applications = []
        self.dbs = []
        self.cache = []
        self.perfs = []
        self.client = None
        self._all_apps = []

    def common_host_setup(self):
        if not os.path.isfile(HOST_SETUP_MARK):
            print("Applying benchmark settings")
            out, err = _RUN_GENERIC_SCRIPT("apps/common-%s-setup.sh" % (self.distribution))
            with open(HOST_SETUP_MARK, "w") as f:
                f.write('ok')
            return out, err
        return '', ''

    def reboot_required(self):
        return os.path.isfile(HOST_REBOOT_REQUIRED)

    def deploy(self):
        outs = []
        errs = []
        for app in self._all_apps:
            print("Deploying %s" % app.name)
            out, err = app.deploy()
            outs.append(out)
            errs.append(err)
        for app in self.perfs:
            print("Deploying %s" % app.name)
            out, err = app.deploy()
            outs.append(out)
            errs.append(err)
        return OUT_SEPARATOR.join(outs), OUT_SEPARATOR.join(errs)

    def start_applications(self):
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.start()
            outs.append(out)
            errs.append(err)
        return OUT_SEPARATOR.join(outs), OUT_SEPARATOR.join(errs)

    def start_performance_measurements(self):
        for app in self.perfs:
            app.start(async=True)
        return '', ''

    def start_benchmark_client(self):
        out, err = self.client.start()
        return out, err

    def stop_applications(self):
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.stop()
            outs.append(out)
            errs.append(err)
        return OUT_SEPARATOR.join(outs), OUT_SEPARATOR.join(errs)

    def stop_performance_measurements(self):
        for app in self.perfs:
            app.stop()
        return '', ''

    def stop_benchmark_client(self):
        out, err = self.client.stop()
        return out, err

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
        perf_data = os.environ['PERF_FILENAME']
        if os.path.isfile(perf_data):
            os.rename(perf_data, '%s/%s' % (measurement_dirs, perf_data))

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
