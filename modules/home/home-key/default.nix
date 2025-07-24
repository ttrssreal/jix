{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jix.homeKey;
in
{
  options.jix.homeKey = {
    enable = lib.mkEnableOption "home key checking";
    generate = lib.mkEnableOption "home key generation";

    privateKey = lib.mkOption {
      type = lib.types.attrs;
      default = {
        path = "${config.home.homeDirectory}/.ssh/jix_ssh_home_ed25519_key";
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
    home.activation = {
      # https://github.com/NixOS/nixpkgs/blob/f593188ca95a/nixos/modules/services/networking/ssh/sshd.nix#L792-L806
      generateHomeKey = lib.mkIf (cfg.enable && cfg.generate) (
        let
          key = cfg.privateKey;
        in
        lib.hm.dag.entryBefore [ "sops-nix" ] ''
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
                ${lib.optionalString (key ? openSSHFormat && key.openSSHFormat) "-o"} \
                -f "${key.path}" \
                -N ""
          fi
        ''
      );

      checkHomeKey = lib.mkIf (cfg.enable && cfg.generate) (
        lib.hm.dag.entryBetween [ "sops-nix" ] [ "generateHomeKey" ] ''
          key=${cfg.privateKey.path}
          pub=${cfg.publicKey}

          if ! [ -f "$key" ]; then
            errorEcho "ERROR: Private key $key missing" >&2
            exit 1
          elif ! [ -f "$pub" ]; then
            errorEcho "ERROR: Public key file $pub missing" >&2
            exit 1
          else
            expected=$(${lib.getExe' pkgs.openssh "ssh-keygen"} -y -f "$key")
            given=$(cat "$pub")

            if [ "$expected" != "$given" ]; then
                errorEcho "ERROR: Public key mismatch!" >&2
                echo "Expected (from $key):" >&2
                echo "$expected" >&2
                echo "Given (in $pub):" >&2
                echo "$given" >&2
            else
              echo "home-key OK"
            fi
          fi
        ''
      );
    };
  };
}
