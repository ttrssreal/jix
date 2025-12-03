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

GITHUB_OUTPUT_ENV = "GITHUB_OUTPUT"
GITHUB_OUTPUT_NAME = "plan"

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

        print(f"{GITHUB_OUTPUT_NAME}={json.dumps(jobs)}")

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--config", help="YAML config")

    sub = parser.add_subparsers(dest="command", required=True)

    plan_parser = sub.add_parser("plan")
    plan_sub = plan_parser.add_subparsers(dest="plan_command", required=True)
    plan_sub.add_parser("eval")
    plan_sub.add_parser("build")

    args = parser.parse_args()

    exit(main(args))
