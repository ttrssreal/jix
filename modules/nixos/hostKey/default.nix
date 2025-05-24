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
        path = "/etc/ssh/ssh_host_ed25519_key";
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
      generateHostKey =
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
                ${lib.optionalString (key ? bits) "-b ${toString key.bits}"} \
                ${lib.optionalString (key ? rounds) "-a ${toString key.rounds}"} \
                ${lib.optionalString (key ? comment) "-C '${key.comment}'"} \
                ${lib.optionalString (key ? openSSHFormat && key.openSSHFormat) "-o"} \
                -f "${key.path}" \
                -N ""
          fi
        '';

      checkHostKey = {
        deps = [ "generateHostKey" ];
        text = ''
          key=${cfg.privateKey.path}
          pub=${cfg.publicKey}

          [ -f "$key" ] || { echo "Error: Private key $key missing" >&2; exit 1; }
          [ -f "$pub" ] || { echo "Error: Public key file $pub missing" >&2; exit 1; }

          expected=$(${lib.getExe' pkgs.openssh "ssh-keygen"} -y -f "$key")
          given=$(cat "$pub")

          if [ "$expected" != "$given" ]; then
              echo "Error: Public key mismatch!" >&2
              echo "Expected (from $key):" >&2
              echo "$expected" >&2
              echo "Given (in $pub):" >&2
              echo "$given" >&2
              exit 1
          fi

          echo "OK: Keys match"
        '';
      };
    };
  };
}
