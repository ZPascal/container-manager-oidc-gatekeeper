#!/usr/bin/python3

import importlib.util
import os
import sys
import requests

spec = importlib.util.spec_from_file_location("module.name", f"{os.environ.get('IMAGE_BASE_DIR')}{os.sep}utils.py")
utils = importlib.util.module_from_spec(spec)
spec.loader.exec_module(utils)

result_local: int = 0
is_process_running: bool = utils.is_supervisor_process_running("app")

if is_process_running is True:
    sys.stdout.write(f"Trying to call main page at {utils.get_env_variable('OIDC_LISTEN_URL')}/oauth/health;")

    result = requests.get(f"http://{utils.get_env_variable('OIDC_LISTEN_URL')}/oauth/health")
    status_code: int = result.status_code
    result_text: str = result.text.replace("\n", "")

    if status_code <= 200 and result_text == "OK":
        sys.stdout.write(f"Health page responded with HTTP Status code {status_code};")
        result_local = 0
    else:
        sys.stdout.write(f"Health page responded with HTTP Status code {status_code} and text {result_text};")
        if bool(utils.get_env_variable("IMAGE_HEALTH_READINESS_FORCE_REBOOT")):
            sys.stderr.write("App is not running. Performing a reboot;")
            response = utils.restart_process("app")

            if response is not True:
                result_local = 1
        else:
            result_local = 1
else:
    sys.stderr.write("App is not running!;")
    if bool(utils.get_env_variable("IMAGE_HEALTH_READINESS_FORCE_REBOOT")):
        sys.stderr.write("App is not running. Performing a reboot;")
        response = utils.restart_process("app")

        if response is not True:
            result_local = 1
    else:
        result_local = 1

sys.exit(result_local)
