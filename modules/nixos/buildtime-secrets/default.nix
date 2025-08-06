{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jix.buildtimeSecrets;
in
{
  options.jix.buildtimeSecrets = {
    enable = lib.mkEnableOption "decrypted secrets";

    decryptionDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/run/buildtime-secrets";
    };
  };

  config = {
    assertions = [
      {
        assertion = config.jix.hostKey.enable;
        message = "This machine needs a hostKey to decrypt buildtime secrets.";
      }
    ];

    nix.settings = {
      system-features = [ "buildtime-secrets" ];
      pre-build-hook = pkgs.writeShellScript "buildtime-secrets-decrypt" ''
        set -eo pipefail

        derivation=$1

        if [ ! -e $derivation ]; then
          >&2 echo "error(buildtime-secrets-decrypt): the derivation $derivation doesn't exist."
          >&2 echo "https://github.com/NixOS/nix/issues/9272"
          exit 1
        fi

        decrypt() {
          secret=$1
          secret_dir=$2

          >&2 echo "debug: decrypting $secret"

          mkdir -p "$secret_dir"

          secret_value=$(
            SOPS_AGE_SSH_PRIVATE_KEY_FILE=${config.jix.hostKey.privateKey.path} \
              ${lib.getExe pkgs.sops} \
                --extract "[\"$secret\"]" \
                -d ${../../../secrets/buildtime.yaml}
          )

          if [ "$secret_value" = "" ]; then
            >&2 echo "error(buildtime-secrets-decrypt): failed to decrypt secret $secret"
            exit 1
          fi

          echo -n "$secret_value" > "$secret_dir/$secret"
        }

        secret_names=$(${lib.getExe pkgs.nix} \
            --extra-experimental-features nix-command \
            derivation show $derivation | \
            ${lib.getExe pkgs.jq} -r \
              "to_entries.[0].value.env.buildtimeSecrets")

        if [ "$secret_names" = "null" ]; then
          >&2 echo "info(buildtime-secrets-decrypt): No buildtime secrets requested for $derivation, Finished."
          exit 0
        fi

        for secret in $secret_names; do
          decrypt $secret "${cfg.decryptionDirectory}"
        done

        echo "extra-sandbox-paths"
        echo "/secrets=${cfg.decryptionDirectory}"
      '';
    };
  };
}
