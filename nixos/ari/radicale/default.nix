{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets = {
    radicale-htpasswd-file.owner = "radicale";

    ari-cert-radicale = {
      owner = "radicale";
      key = "ari-cert";
    };

    ari-cert-key-radicale = {
      owner = "radicale";
      key = "ari-cert-key";
    };
  };

  services = {
    radicale = {
      enable = true;
      settings = {
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets.radicale-htpasswd-file.path;
          htpasswd_encryption = "autodetect";
        };

        server = {
          ssl = true;
          hosts = "0.0.0.0:5232";
          certificate = config.sops.secrets.ari-cert-radicale.path;
          key = config.sops.secrets.ari-cert-key-radicale.path;
        };
      };
    };
  };

  systemd.services.radicale-test = {
    description = "Test radicale";

    serviceConfig = {
      Environment = [
        "CALDAV_USERNAME=test-user"
        "CALDAV_URL=https://ari.mudpuppy-cod.ts.net:5232"
        "CALDAV_PASSWORD=test-user"
      ];
      ExecStart = "${lib.getExe (
        pkgs.writeShellApplication {
          name = "radicale-test-exec-start";

          runtimeInputs = [
            pkgs.curl
            (pkgs.python3.withPackages (py: [
              py.caldav
            ]))
          ];

          text = ''
            if ! python ${./test-radicale.py}; then
              exit 1
            fi

            curl https://hc-ping.com/6fe30583-6d5a-4a24-9597-91fef765ad73
          '';
        }
      )}";
    };
  };

  systemd.timers.radicale-test = {
    description = "Test radicale timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "radicale-test.service" ];

    timerConfig = {
      # https://systemd.guru/#*-*-*%20*%3A00%2C30%3A00
      OnCalendar = "*-*-* *:00,30:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
