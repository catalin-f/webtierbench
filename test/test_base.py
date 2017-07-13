from _base import _RUN_GENERIC_SCRIPT
from _base import _file_exists
from _base import Platform
from _base import Deployment
from _base import set_env
from _base import parse_deploy_args
from _base import parse_run_args
from _base import _check_ipv4
from _base import _Logger
from _base import pickle_deployment
import os
import stat
import argparse
import pytest
import platform
import sys
import socket


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


def test_pickle_deployment():
    myplatform = Platform()
    myplatform.detect()
    deployment = Deployment('test_deployment', {}, myplatform)
    pickle_deployment(deployment)
    assert os.path.isfile(".deployment.pickle")


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


