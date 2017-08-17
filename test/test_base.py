from _base import _RUN_GENERIC_SCRIPT
from _base import _HOST_REBOOT_REQUIRED
from _base import _file_exists
from _base import Platform
from _base import Deployment
from _base import set_env
from _base import parse_deploy_args
from _base import parse_run_args
from _base import _check_ipv4
from _base import root_access
from _base import _Logger
from _base import pickle_deployment
from _base import unpickle_deployment
from _base import load_run_configuration
from _base import Application
import os
import stat
import argparse
import pytest
import platform
import sys
import socket
import json


def _create_dummy_script():
    name = "/tmp/dummyscript"
    with open(name, "w") as temp:
        temp.write('''#!/usr/bin/env python
import sys

sys.stdout.write("stdout_msg")
sys.stderr.write("stderr_msg")
        ''')
        temp.flush()
    st = os.stat(name)
    os.chmod(name, st.st_mode | stat.S_IEXEC)
    return name


def _create_empty_file():
    name = "/tmp/emptyfile"
    with open(name, "w") as temp:
        temp.write("")
        temp.flush()
    return name


def _create_run_json_inputfile(createExtraFile=True):
    if createExtraFile:
        empty_file = _create_empty_file()
    else:
        empty_file = ""
    config = {
        "scenario": "file",
        "workers": 4,
        "duration": 120,
         "settings":{
            "filename": empty_file
        }
    }
    name = "/tmp/inputfile.json"
    with open(name, "w") as temp:
        temp.write(json.dumps(config))
        temp.flush()
    return name, empty_file


class MyApp(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MyApp, self).__init__("_test_app", deploy_config, deploy_platform)


class MyCache(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MyCache, self).__init__("_test_cache", deploy_config, deploy_platform)


class MyClient(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MyClient, self).__init__("_test_client", deploy_config, deploy_platform)


class MyDb(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MyDb, self).__init__("_test_db", deploy_config, deploy_platform)


class MyPerf(Application):
    def __init__(self, deploy_config, deploy_platform):
        super(MyPerf, self).__init__("_test_perf", deploy_config, deploy_platform)


###############################################################################
# Tests
###############################################################################
def test_run_generic_script():
    script = _create_dummy_script()

    out, err = _RUN_GENERIC_SCRIPT(script, async=False)
    assert out == "stdout_msg"
    assert err == "stderr_msg"

    out, err = _RUN_GENERIC_SCRIPT(script, async=True)
    assert out == ""
    assert err == ""


def test_set_env():
    set_env("WEBTIER_TESTING", "123")
    assert os.environ["WEBTIER_TESTING"] == "123"
    os.environ["WEBTIER_TESTING"] == ""


def test_platform():
    myplatform = Platform()
    myplatform.detect()
    assert myplatform.system == platform.system().lower()
    assert myplatform.type == os.name


def test_root_access():
    has_root = root_access()
    assert has_root == (os.geteuid()==0)


def test_pickle_unpickle_deployment():
    myplatform = Platform()
    myplatform.detect()
    deployment = Deployment('test_deployment', {}, myplatform)
    pickle_deployment(deployment)
    assert os.path.isfile(".deployment.pickle")
    deployment = unpickle_deployment()
    assert deployment.name == 'test_deployment'


def test_file_exists():
    file = _create_empty_file()
    assert _file_exists(file) == file

    with pytest.raises(argparse.ArgumentTypeError) as excinfo:
        _file_exists("")
    assert excinfo.match("Please specify an input filename")

    with pytest.raises(argparse.ArgumentTypeError) as excinfo:
        _file_exists("blabla")
    assert excinfo.match("Please use a valid filename")


def test_parse_deploy_args(capsys):
    file = _create_empty_file()
    cmd = './run'

    sys.argv = [cmd, "-s", file]
    config = parse_deploy_args()
    assert config == file

    sys.argv = [cmd, "--setup", file]
    config = parse_deploy_args()
    assert config == file

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "-s"]
        config = parse_deploy_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "--setup"]
        config = parse_deploy_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "-randomparameter"]
        config = parse_deploy_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd]
        config = parse_deploy_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")


def test_parse_run_args(capsys):
    file = _create_empty_file()
    cmd = './run'

    sys.argv = [cmd, "-b", file]
    config = parse_run_args()
    assert config == file

    sys.argv = [cmd, "--benchmark", file]
    config = parse_run_args()
    assert config == file

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "-b"]
        config = parse_run_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "--benchmark"]
        config = parse_run_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd, "-randomparameter"]
        config = parse_run_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")

    with pytest.raises(SystemExit) as excinfo:
        sys.argv = [cmd]
        config = parse_run_args()
    out, err = capsys.readouterr()
    assert err.startswith("usage: ")


def test_load_run_configuration_inputfile(capsys):
    file, extra_file = _create_run_json_inputfile(createExtraFile=True)
    config_json = load_run_configuration(file)
    assert config_json["settings"]["filename"] == extra_file

    os.remove(file)

    out, err = capsys.readouterr()
    assert out == ''


def test_check_ipv4():
    msg = 'illegal IP address string passed to inet_aton'

    with pytest.raises(socket.error) as excinfo:
        _check_ipv4("127.0.0.a")
    assert excinfo.match(msg)

    with pytest.raises(socket.error) as excinfo:
        _check_ipv4("localhost")
    assert excinfo.match(msg)


def test_logger(capsys):
    file = _create_empty_file()
    temp_logger = _Logger(file, showTimestamp=False).log

    temp_logger("abcd")
    with open(file, "r") as temp:
        line = temp.readlines()
    assert line[0] == "abcd\n"

    temp_logger("efgh")
    with open(file, "r") as temp:
        line = temp.readlines()
    assert line[0] == "abcd\n"
    assert line[1] == "efgh\n"

    temp_logger = _Logger("", showTimestamp=False).log
    temp_logger("ijkl")
    out, err = capsys.readouterr()
    assert out == "ijkl\n"


def test_reboot_required():
    try:
        os.unlink(_HOST_REBOOT_REQUIRED)
    except:
        pass

    deployment = Deployment('', {}, Platform())
    assert not deployment.reboot_required()

    with open(_HOST_REBOOT_REQUIRED, "w") as temp:
        temp.write("")
        temp.flush()
    assert deployment.reboot_required()

    os.unlink(_HOST_REBOOT_REQUIRED)
    assert not deployment.reboot_required()


def test_deployment_basic():
    myplatform = Platform()
    myplatform.detect()
    deployment = Deployment('simple_deployment', {}, myplatform)

    assert deployment.name == 'simple_deployment'
    assert len(deployment.applications) == 0
    assert len(deployment.dbs) == 0
    assert len(deployment.cache) == 0
    assert len(deployment.perfs) == 0
    assert deployment.client == None
    assert len(deployment._all_apps) == 0

    empty = ''

    out, err = deployment.deploy()
    assert out == empty and err == empty

    out, err = deployment.start_applications()
    assert out == empty and err == empty

    out, err = deployment.start_performance_measurements()
    assert out == empty and err == empty

    out, err = deployment.start_benchmark_client()
    assert out == empty and err == empty

    out, err = deployment.stop_applications()
    assert out == empty and err == empty

    out, err = deployment.stop_performance_measurements()
    assert out == empty and err == empty

    out, err = deployment.stop_benchmark_client()
    assert out == empty and err == empty


def test_deployment_advanced():
    myplatform = Platform()
    myplatform.detect()
    deployment = Deployment('advanced_deployment', {}, myplatform)
    assert deployment.name == 'advanced_deployment'

    # add custom runners and apps
    def TEST_RUN_APP_SCRIPT(name, platform, script, async=False):
        cmd = "test/%s/%s/%s" % (name, platform.distribution, script)
        return _RUN_GENERIC_SCRIPT(cmd, async)
    import _base
    _base.__dict__['_ALLOWED_APPLICATIONS'] = ['_test_app', '_test_cache', '_test_client', '_test_db', '_test_perf']
    _base.__dict__['RUN_APP_SCRIPT'] = TEST_RUN_APP_SCRIPT

    test_app = MyApp({}, myplatform)
    test_cache = MyCache({}, myplatform)
    test_client = MyClient({}, myplatform)
    test_db = MyDb({}, myplatform)
    test_perf = MyPerf({}, myplatform)

    deployment.add_application(test_app)
    deployment.add_cache(test_cache)
    deployment.set_client(test_client)
    deployment.add_db(test_db)
    deployment.add_perf(test_perf)

    assert len(deployment.applications) == 1
    assert len(deployment.dbs) == 1
    assert len(deployment.cache) == 1
    assert len(deployment.perfs) == 1
    assert deployment.client != None
    assert len(deployment._all_apps) == 4

    out, err = deployment.deploy()
    assert out == "deploy app\n deploy cache\n deploy client\n deploy db\n deploy perf\n"
    assert err.strip() == ''

    out, err = deployment.start_performance_measurements()
    assert out == ''
    assert err.strip() == ''

    out, err = deployment.start_benchmark_client()
    assert out == 'start client\n'
    assert err.strip() == ''

    out, err = deployment.stop_benchmark_client()
    assert out == 'stop client\n'
    assert err.strip() == ''

    out, err = deployment.stop_performance_measurements()
    assert out == ''
    assert err == ''

    out, err = deployment.stop_applications()
    assert out == "stop app\n stop cache\n stop db\n"
    assert err.strip() == ''
