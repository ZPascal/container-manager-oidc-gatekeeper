#!/usr/bin/python3

import importlib.util
import os
import sys
import subprocess

spec = importlib.util.spec_from_file_location("module.name", f"{os.environ.get('IMAGE_BASE_DIR')}{os.sep}utils.py")
utils = importlib.util.module_from_spec(spec)
spec.loader.exec_module(utils)

result_local = utils.is_supervisor_process_running("app")

if result_local == 0:
    sys.stdout.write(f"Trying to call main page at {utils.get_env_variable('OIDC_LISTEN_URL')}/oauth/health;")

    command = ["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}",
               f"{utils.get_env_variable('OIDC_LISTEN_URL')}/oauth/health"]

    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)

    if result != 0:
        sys.stderr.write("Main page didn't respond!;")
        if bool(utils.get_env_variable("IMAGE_HEALTH_READINESS_FORCE_REBOOT")):
            response = utils.restart_process("app")

            if response is not None:
                result_local = 1
        else:
            result_local = 1
    else:
        sys.stdout.write(f"Main page responded with HTTP Status {result.stdout}")
        if 200 <= int(result.stdout) <= 400:
            result_local = 0
        else:
            sys.stderr.write("Main page could not be called.;")
            if bool(utils.get_env_variable("IMAGE_HEALTH_READINESS_FORCE_REBOOT")):
                response = utils.restart_process("app")

                if response is not None:
                    result_local = 1
            else:
                result_local = 1
else:
    sys.stderr.write("Exporter is not running!;")

sys.exit(result_local)
