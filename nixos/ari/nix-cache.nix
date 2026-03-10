{
  config,
  pkgs,
  lib,
  ...
}:
let
  api-endpoint = "https://ari.mudpuppy-cod.ts.net/nix-cache/";
in
{
  sops.secrets.attic-server-token = { };

  sops.templates.atticEnvFile.content = ''
    ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder.attic-server-token}
  '';

  systemd.services.config-attic = {
    enable = true;
    serviceConfig.Type = "simple";

    path = [
      pkgs.attic-server
      pkgs.attic-client
      pkgs.bash
      (lib.findFirst (p: p.name == "atticd-atticadm") (throw ''
        Couldn't find atticd-atticadm in environment.systemPackages. Need it to configure attic
      '') config.environment.systemPackages)
    ];

    requiredBy = [
      "multi-user.target"
    ];

    script = ''
      export XDG_CONFIG_HOME="$(mktemp -d)"

      cleanup() {
        rm -rf "$XDG_CONFIG_HOME"
      }

      trap cleanup EXIT

      attic login nix-cache ${api-endpoint} "$(atticd-atticadm make-token \
        --sub initial-configure \
        --validity 1d \
        --push '*' \
        --pull '*' \
        --delete  '*' \
        --create-cache '*' \
        --configure-cache '*' \
        --configure-cache-retention '*' \
        --destroy-cache '*')"

      if ! 2>/dev/null attic cache info main; then
        >&2 echo "info: creating cache 'main'"
        attic cache create main
      fi
    '';
  };

  services.atticd = {
    enable = true;

    environmentFile = config.sops.templates.atticEnvFile.path;

    settings = {
      inherit api-endpoint;
      listen = "127.0.0.1:1234";

      jwt = { };

      storage = {
        type = "local";
        path = "/var/lib/atticd";
      };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";
    proxyTimeout = "3600"; # 1hr

    virtualHosts."ari.mudpuppy-cod.ts.net" = {
      locations."/nix-cache/" = {
        proxyPass = "http://127.0.0.1:1234/";
      };
    };
  };
}
