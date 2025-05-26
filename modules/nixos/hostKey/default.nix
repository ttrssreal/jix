{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jix.hostKey;
in
{
  options.jix.hostKey = {
    generate = lib.mkEnableOption "host key generation";

    privateKey = lib.mkOption {
      type = lib.types.attrs;
      default = {
        path = "/etc/ssh/jix_ssh_host_ed25519_key";
        type = "ed25519";
        bits = 521;
      };
    };

    publicKey = lib.mkOption {
      type = lib.types.path;
      description = "The associated public key";
    };
  };

  config = {
    system.activationScripts = {
      # https://github.com/NixOS/nixpkgs/blob/f593188ca95a/nixos/modules/services/networking/ssh/sshd.nix#L792-L806
      generateHostKey = lib.mkIf cfg.generate (
        let
          key = cfg.privateKey;
        in
        ''
          if ! [ -s "${key.path}" ]; then
              if ! [ -h "${key.path}" ]; then
                  rm -f "${key.path}"
              fi
              mkdir -p "$(dirname '${key.path}')"
              chmod 0755 "$(dirname '${key.path}')"
              ${lib.getExe' pkgs.openssh "ssh-keygen"} \
                -t "${key.type}" \
                -C "root@${config.networking.hostName}" \
                ${lib.optionalString (key ? bits) "-b ${toString key.bits}"} \
                ${lib.optionalString (key ? rounds) "-a ${toString key.rounds}"} \
                ${lib.optionalString (key ? openSSHFormat && key.openSSHFormat) "-o"} \
                -f "${key.path}" \
                -N ""
          fi
        ''
      );

      checkHostKey = {
        deps = lib.optional cfg.generate "generateHostKey";
        text = ''
          key=${cfg.privateKey.path}
          pub=${cfg.publicKey}

          if ! [ -f "$key" ]; then
            echo "ERROR: Private key $key missing" >&2
          elif ! [ -f "$pub" ]; then
            echo "ERROR: Public key file $pub missing" >&2
          else
            expected=$(${lib.getExe' pkgs.openssh "ssh-keygen"} -y -f "$key")
            given=$(cat "$pub")

            if [ "$expected" != "$given" ]; then
                echo "ERROR: Public key mismatch!" >&2
                echo "Expected (from $key):" >&2
                echo "$expected" >&2
                echo "Given (in $pub):" >&2
                echo "$given" >&2
            else
              echo "host-key OK"
            fi
          fi
        '';
      };
    };
  };
}
