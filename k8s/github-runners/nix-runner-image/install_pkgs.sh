#!/bin/bash
set -exo pipefail

declare -r toolset=$1

package_set=$(cat $toolset | jq -r "(.apt.vital_packages + .apt.common_packages + .apt.cmd_packages)[]")

apt-get install --no-install-recommends $package_set -y
