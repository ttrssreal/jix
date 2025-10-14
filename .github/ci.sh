#!/usr/bin/env nix
#! nix shell
#! nix nixpkgs#nix
#! nix nixpkgs#yq
#! nix nixpkgs#jq
#! nix nixpkgs#coreutils
#! nix nixpkgs#systemd
#! nix --command bash

if [ $# -lt 1 ]; then
  echo "usage: $0 <command>"
fi

is_eval=false
is_build=false
is_install=false

if [ "$1" = "eval" ]; then
  is_eval=true
elif [ "$1" = "build" ]; then
  is_build=true
elif [ "$1" = "install" ]; then
  is_install=true
else
  echo "Unknown command: $1. Use 'eval', 'build' or 'install'"
  exit 1
fi

if [ "$is_install" = true ]; then
  if [ "$(id -u)" != "0" ]; then
    echo "error: install action needs to run as root"
    exit 1
  fi

  config_file=$(mktemp)
  pre_build_hook=$(mktemp)
  key=$(mktemp)

  [[ -z "$CI_KEY" ]] \
    && { echo "No environment variable CI_KEY"; exit 1; }

  echo >$key "$CI_KEY"

  btsn="$(
    nix build \
      github:ttrssreal/buildtime-secrets-nix \
      --print-out-paths \
      --no-link
  )"

  {
    echo '{'
    echo '  "backend_config": {'
    echo '    "sops": {'
    echo '      "environment": {'
    echo "        \"SOPS_AGE_SSH_PRIVATE_KEY_FILE\": \"$key\""
    echo '      },'
    echo "      \"sops_file\": \"$PWD/secrets/buildtime.yaml\""
    echo '    }'
    echo '  },'
    echo '  "secret_dir": "/run/bt-secrets"'
    echo '}'
  } > "$config_file"

  {
    echo '#!/usr/bin/env bash'
    echo export RUST_LOG=debug
    echo export PATH="$(nix build nixpkgs#sops --print-out-paths --no-link)/bin"
    echo export LOG_FILE=/var/log/buildtime-secrets/log
    echo export CONFIG_FILE="$config_file"
    echo "$btsn"/bin/buildtime-secrets-nix "\$@"
  } > "$pre_build_hook"

  {
    echo "system-features = buildtime-secrets"
    echo "pre-build-hook = $pre_build_hook"
  } |>/dev/null tee -a /etc/nix/nix.custom.conf

  chmod +x "$pre_build_hook"

  echo "/etc/nix.custom.conf updated, restarting nix-daemon..."
  systemctl restart nix-daemon

  echo -e "\033[1;32mSuccessfully installed buildtime-secrets-nix!\033[0m"

  exit 0
fi

paths=$(
  yq -j ".$1" .github/ci.yaml | jq -r '
    def leaves:
      if type == "array" or type == "object" then
        .[] | leaves
      else
        .
      end;

    path(leaves) | join(".")
  '
)

succeeded=()
failed=()

for path in $paths; do
  if [ "$is_eval" = true ]; then
    echo "🔎 Evaluating \"$path\" ..."
    if nix eval .#"$path" -L; then
      succeeded+=("$path")
    else
      failed+=("$path")
    fi
  elif [ "$is_build" = true ]; then
    echo "⚒️  Building \"$path\" ..."
    if nix build .#"$path" -L --no-link; then
      succeeded+=("$path")
    else
      failed+=("$path")
    fi
  fi
done

echo
echo "✅ Succeeded:"
for s in "${succeeded[@]}"; do echo "  $s"; done

echo
echo "❌ Failed:"
for f in "${failed[@]}"; do echo "  $f"; done

if [ "${#failed[@]}" -ne 0 ]; then
  exit 1
fi
