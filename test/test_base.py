from _base import _RUN_GENERIC_SCRIPT
from _base import _file_exists
import os
import stat
import argparse
import pytest


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


def test_file_exists():
    file = _create_empty_file()
    assert _file_exists(file) == file

    with pytest.raises(argparse.ArgumentTypeError) as excinfo:
        _file_exists("")
    assert excinfo.match("Please specify an input filename")

    with pytest.raises(argparse.ArgumentTypeError) as excinfo:
        _file_exists("blabla")
    assert excinfo.match("Please use a valid filename")
