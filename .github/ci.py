#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/cadcc8de247676e4751c9d4a935acb2c0b059113.tar.gz
#! nix-shell -p python3
#! nix-shell -p python3Packages.requests
#! nix-shell -p python3Packages.pyyaml
#! nix-shell -p nix
#! nix-shell -p systemd
#! nix-shell -i python3

import argparse
import yaml
import subprocess
import os
import shutil
import shutil
import json
from enum import Enum
import re

GITHUB_OUTPUT_ENV = "GITHUB_OUTPUT"
GITHUB_OUTPUT_NAME = "plan"
GITHUB_STEP_SUMMARY_ENV = "GITHUB_STEP_SUMMARY"
NIX_INTERNAL_JSON_PREFIX = "@nix "

# https://github.com/NixOS/nix/blob/d85e5dfa60e7ac33b2c427f226b147982b8bd4e7/src/libutil/include/nix/util/error.hh#L33
NIX_LOG_LEVELS = {
    "error": 0,
    "warn": 1,
    "notice": 2,
    "info": 3,
}

# https://stackoverflow.com/a/14693789
# 7-bit C1 ANSI sequences
ANSI_ESCAPE = re.compile(r'''
    \x1B  # ESC
    (?:   # 7-bit C1 Fe (except CSI)
        [@-Z\\-_]
    |     # or [ for CSI, followed by a control sequence
        \[
        [0-?]*  # Parameter bytes
        [ -/]*  # Intermediate bytes
        [@-~]   # Final byte
    )
''', re.VERBOSE)

class JobType(Enum):
    EVAL = 1
    BUILD = 2

def format_nix_cmd(cmd, local=True):
    return [
        shutil.which("nix") if local else "nix",
        "--extra-experimental-features",
        "nix-command flakes"
    ] + cmd

def nix(cmd):
    return subprocess.run(
        format_nix_cmd(cmd),
        env={ "NO_COLOR": "1" },
        text=True,
        capture_output=True
    )

def load_config(args):
    try:
        with open(args.config) as f:
            return yaml.safe_load(f) 
    except Exception as e:
        raise RuntimeError("failed to load config") from e

def home_jobs(jobs, job_type):
    raw = nix([
        "eval",
        ".#homeConfigurations",
        "--apply",
        "builtins.attrNames",
        "--json"
    ])

    home_configs = json.loads(raw.stdout)
    for home in home_configs:
        attr_path = f"homeConfigurations.{home}.activationPackage"
        subcommand = "eval" if job_type == JobType.EVAL else "build"

        command = format_nix_cmd([subcommand, f".#{attr_path}", "-L"], local=False)
        command_quoted = " ".join(map(lambda x: f"'{x}'", command))

        jobs.append({
            "name": f"{home} (home-manager configuration)",
            "command": command_quoted
        })

def nixos_jobs(jobs, job_type):
    raw = nix([
        "eval",
        ".#nixosConfigurations",
        "--apply",
        "builtins.attrNames",
        "--json"
    ])

    nixos_configs = json.loads(raw.stdout)
    for nixos in nixos_configs:
        attr_path = f"nixosConfigurations.{nixos}.config.system.build.toplevel"
        subcommand = "eval" if job_type == JobType.EVAL else "build"

        command = format_nix_cmd([subcommand, f".#{attr_path}", "-L"], local=False)
        command_quoted = " ".join(map(lambda x: f"'{x}'", command))

        jobs.append({
            "name": f"{nixos} (nixos configuration)",
            "command": command_quoted
        })

def package_jobs(jobs, job_type):
    currentSystem = nix([
        "eval",
        "--impure",
        "--raw",
        "--expr",
        "builtins.currentSystem",
    ]).stdout

    raw = nix([
        "eval",
        f".#packages.{currentSystem}",
        "--apply",
        "builtins.attrNames",
        "--json"
    ])

    packages = json.loads(raw.stdout)
    for package in packages:
        subcommand = "eval" if job_type == JobType.EVAL else "build"

        command = format_nix_cmd([subcommand, f".#{package}", "-L"], local=False)
        command_quoted = " ".join(map(lambda x: f"'{x}'", command))

        jobs.append({
            "name": f"{package} (package)",
            "command": command_quoted
        })

def plan(args, config, job_type):
    config = config["build"]
    jobs = list()

    if config["homeConfigurations"]:
        home_jobs(jobs, job_type)

    if config["nixosConfigurations"]:
        nixos_jobs(jobs, job_type)

    if config["packages"]:
        package_jobs(jobs, job_type)

    return jobs

def main(args):
    if args.command == "plan":
        config = load_config(args)

        if args.plan_command == "eval":
            jobs = plan(args, config, JobType.EVAL)

        if args.plan_command == "build":
            jobs = plan(args, config, JobType.BUILD)

        if args.test_job:
            jobs = [ job for job in jobs if job["name"] == args.test_job ]

        print(f"{GITHUB_OUTPUT_NAME}={json.dumps(jobs)}")

    if args.command == "run":
        if args.nix_command[0] != "nix":
            print("error: run: not a nix command")
            return 1

        nix_command = [ shutil.which("nix") ]
        nix_command += args.nix_command[1:]
        nix_command += [ "--log-format", "internal-json" ]

        messages = list()
        process = subprocess.Popen(
            nix_command,
            env={ "NO_COLOR": "1" },
            text=True,
            stderr=subprocess.PIPE
        )

        for line in process.stderr:
            raw_json = line.lstrip(NIX_INTERNAL_JSON_PREFIX)
            log = json.loads(raw_json)

            if "text" in log:
                print(log["text"])

            if log["action"] == "msg" and log["level"] < NIX_LOG_LEVELS["info"]:
                msg = log["msg"]
                print(log["msg"])

                message = {
                    "level": log["level"],
                    "msg": msg
                }

                messages += [ message ]

        summary = list()
        summary += [ "<details>" ]
        summary += [ f"<summary>⚠️ ({len(messages)})</summary>\n\n" ]

        def ansi_escape(msg):
            return ANSI_ESCAPE.sub("", msg)

        for message in messages:
            summary += [ f"- {ansi_escape(message["msg"])}"  ]

        summary += [ "</details>" ]

        summary_file = os.environ.get(GITHUB_STEP_SUMMARY_ENV)
        if not summary_file:
            print(f"error: no {GITHUB_STEP_SUMMARY_ENV} environment variable")
            return 1

        with open(summary_file, "w") as f:
            f.write("\n".join(summary))

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--config", help="YAML config")
    parser.add_argument("-t", "--test-job", help="Only output the first planed job")

    sub = parser.add_subparsers(dest="command", required=True)

    plan_parser = sub.add_parser("plan")
    plan_sub = plan_parser.add_subparsers(dest="plan_command", required=True)
    plan_sub.add_parser("eval")
    plan_sub.add_parser("build")

    run_parser = sub.add_parser("run")
    run_parser.add_argument(dest="nix_command", help="The nix command to run", nargs=argparse.REMAINDER)

    args = parser.parse_args()

    exit(main(args))
