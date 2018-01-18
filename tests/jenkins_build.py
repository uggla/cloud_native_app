#!/usr/bin/env python3

from __future__ import print_function

import os
import subprocess, shlex
import sys

script_dir = os.path.dirname(os.path.realpath(__file__))
tests_dir = os.path.join(script_dir, "testfiles")

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def run_cmd_out(command):
    process = subprocess.Popen(command,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                encoding="utf-8")

    full_stdout = ""

    while True:
        errput = process.stderr.readline()
        output = process.stdout.readline()

        if not output and not errput and process.poll() is not None:
            break
        if errput:
            eprint(errput, end='')
        if output:
            full_stdout += output
            print(output, end='')

    retcode = process.poll()

    if retcode != 0:
        e = subprocess.CalledProcessError(returncode=retcode, cmd=command)
        e.stdout = full_stdout

        raise e

    return full_stdout

def run_cmd(command):
    run_cmd_out(command)

def setup_env():
    env_id = False

    try:
        os.chdir(script_dir)

        env_id = run_cmd_out(os.path.join(script_dir, "setup_env.sh"))

        print("Docker id: " + env_id)
    except CalledProcessError as e:
        env_id = e.stdout

        if env_id:
            stop_env(env_id)

        raise e

    return env_id

def run_tests(env_id):
    run_cmd([os.path.join(script_dir, "run_tests.sh"), env_id])

def stop_env(env_id):
    run_cmd([script_dir + "/stop_env.sh", env_id])

def main():
    try:
        env_id = setup_env()

        run_tests(env_id)

    finally:
        if env_id:
            stop_env(env_id)

    exit(0)

if __name__ == "__main__":
    main()
