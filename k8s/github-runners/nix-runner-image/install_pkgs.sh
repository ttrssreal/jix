#!/bin/bash
set -exo pipefail

declare -r toolset=$1

package_set=$(cat $toolset | jq -r "(.apt.vital_packages + .apt.common_packages + .apt.cmd_packages)[]")
gh_cli_rel_url=https://github.com/cli/cli/releases/download/v2.64.0/gh_2.64.0_linux_amd64.deb
gh_cli_path=/tmp/gh_cli.deb

apt-get install --no-install-recommends $package_set -y

curl -Lo $gh_cli_path $gh_cli_rel_url
apt-get install $gh_cli_path
