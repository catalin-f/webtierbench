import datetime
import os
import platform
import pickle
import subprocess


WEBTIER_VERSION = "1.0"


###############################################################################
# Common functions and classes
###############################################################################
def _RUN_GENERIC_SCRIPT(name):
    #return os.system(name)
    proc = subprocess.Popen(name, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out = proc.stdout.read()
    err = proc.stderr.read()
    return out, err


def RUN_SCRIPT(name, distribution, version, script):
    cmd = "apps/%s/%s/%s" % (name, distribution, script)
    return _RUN_GENERIC_SCRIPT(cmd)


def detect_os():
    type = os.name
    distribution = None
    version = None
    if type == 'posix':
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
            today = datetime.date.today()
            return "[%s] " % today.strftime('%Y-%m-%d %H:%M:%S')
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

#TODO: add code for common-XXX-setup.sh to not block in a reboot loop forever
HOST_SETUP_MARK = '.host.setup.done'


class Application:
    def __init__(self, name, config, distribution, version):
        if not name in ALLOWED_APPLICATIONS:
            raise NotImplementedError("Unknown application: %s" % (name))
        self.name = name
        self.config = config
        self.distribution = distribution
        self.version = version

    def deploy(self):
        #TODO use config
        out, err = RUN_SCRIPT(self.name, self.distribution, self.version, "deploy.sh")
        return out, err

    def undeploy(self):
        # TODO use config
        out, err = RUN_SCRIPT(self.name, self.distribution, self.version, "undeploy.sh")
        return out, err

    def start(self):
        # TODO use config
        out, err = RUN_SCRIPT(self.name, self.distribution, self.version, "start.sh")
        return out, err

    def stop(self):
        # TODO use config
        out, err = RUN_SCRIPT(self.name, self.distribution, self.version, "stop.sh")
        return out, err


class Deployment:
    def __init__(self, name, distribution, version):
        self.distribution = distribution
        self.version = version
        if distribution == 'mac':
            raise NotImplementedError("This operating system is not yet supported")
        self.name = name
        self.applications = []
        self.dbs = []
        self.cache = []
        self.perfs = []
        self.client = None
        self._all_apps = []

    def common_host_setup(self):
        out, err = _RUN_GENERIC_SCRIPT("apps/common-%s-setup.sh" % (self.distribution))
        with open(HOST_SETUP_MARK, "w") as f:
            f.write('ok')
        return out, err

    def deploy(self):
        outs = []
        errs = []
        for app in self._all_apps:
            print("Deploying %s" % app.name)
            out, err = app.deploy()
            outs.append(out)
            errs.append(err)
        return ' '.join(outs), ' '.join(errs)

    def start_applications(self):
        #TODO add more env data
        os.environ['PERF_FILENAME'] = 'myperf.data'
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.start()
            outs.append(out)
            errs.append(err)
        return ' '.join(outs), ' '.join(errs)

    def stop_applications(self):
        outs = []
        errs = []
        for app in self._all_apps:
            out, err = app.stop()
            outs.append(out)
            errs.append(err)
        # TODO del more env data
        os.environ['PERF_FILENAME'] = ''
        return ' '.join(outs), ' '.join(errs)

    def start_benchmark(self):
        # TODO: add _all_ data needed for benchmark
        os.environ['WEBTIER_IP'] = 'localhost'
        os.environ['WEBTIER_PORT'] = '80'
        out, err = self.client.start()
        return out, err

    def stop_benchmark(self):
        out, err = self.client.stop()
        os.environ['WEBTIER_IP'] = ''
        os.environ['WEBTIER_PORT'] = ''
        return out, err

    def collect_performance_data(self):
        os.system('mkdir -p measurements/%s' % self.name)
        os.system('cp -f myperf.data measurements/%s/.' % self.name)

    #####
    def add_application(self, name, config):
        app = Application(name, config, self.distribution, self.version)
        self.applications.append(app)
        self._all_apps.append(app)

    def add_db(self, name, config):
        app = Application(name, config, self.distribution, self.version)
        self.dbs.append(app)
        self._all_apps.append(app)

    def add_cache(self, name, config):
        app = Application(name, config, self.distribution, self.version)
        self.cache.append(app)
        self._all_apps.append(app)

    def add_perf(self, name, config):
        app = Application(name, config, self.distribution, self.version)
        self.perfs.append(app)
        self._all_apps.append(app)

    def set_client(self, name, config):
        app = Application(name, config, self.distribution, self.version)
        self.client = app
        self._all_apps.append(app)
