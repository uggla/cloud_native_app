#!/usr/bin/env python3

from __future__ import print_function

import os
import subprocess
import sys

script_dir = os.path.dirname(os.path.realpath(__file__))
tests_dir = os.path.join(script_dir, "testfiles")

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def setup_env():
    try:
        os.chdir(script_dir)

        result = subprocess.run([script_dir + "/setup_env.sh"],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    check=True, errors="pass")
        eprint(result.stderr)

        env_id = result.stdout
        print("Docker id: " + env_id)

    except subprocess.CalledProcessError as result:
        eprint(result.stderr)

        env_id = result.stdout
        print("Docker id: " + env_id)

        if env_id:
            stop_env(env_id)
        raise result

    return env_id

def run_test(testfile, env_id):
    try:
        result = subprocess.run([script_dir + "/run_test.sh", env_id, testfile],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    check=True, errors="pass")
        print(result.stdout)
        eprint(result.stderr)

    except subprocess.CalledProcessError as result:
        print(result.stdout)
        eprint(result.stderr)

        stop_env(env_id)
        raise result

def stop_env(env_id):
    try:
        result = subprocess.run([script_dir + "/stop_env.sh", env_id],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    check=True, errors="pass")
        print(result.stdout)
        eprint(result.stderr)

    except subprocess.CalledProcessError as result:
        print(result.stdout)
        eprint(result.stderr)

        raise result

def main():
    env_id = setup_env()

    for entry in os.scandir(tests_dir):
        if entry.is_file():
            print ("Starting " + entry.path)
            run_test(entry.path, env_id)

    stop_env(env_id)

    exit(0)

if __name__ == "__main__":
    main()
