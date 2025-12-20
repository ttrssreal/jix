{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets = {
    ari-cert-grafana = {
      owner = "nginx";
      key = "ari-cert";
    };

    ari-cert-key-grafana = {
      owner = "nginx";
      key = "ari-cert-key";
    };

    grafana-password = {
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "ari.mudpuppy-cod.ts.net";
        root_url = "https://ari.mudpuppy-cod.ts.net/grafana/";
        serve_from_sub_path = true;
      };

      security = {
        admin_user = "jess";
        admin_password = "$__file{${config.sops.secrets.grafana-password.path}}";
      };
    };
  };

  systemd.services.grafana-test = {
    description = "Test grafana";

    serviceConfig.ExecStart = "${lib.getExe (
      pkgs.writeShellApplication {
        name = "grafana-test-exec-start";

        runtimeInputs = [
          pkgs.curl
          pkgs.jq
        ];

        text = ''
          set -xeo pipefail

          response=$(curl --fail https://ari.mudpuppy-cod.ts.net/grafana/api/health)

          database=$(echo "$response" | jq -r '.database')
          if [ "$database" != "ok" ]; then
            echo 'Grafana database returned failure healthcheck'
            exit 1
          fi

          res=$(echo "$response" | jq 'has("version")')
          if [ "$res" != "true" ]; then
            echo 'Grafana database healthcheck returned the wrong json!!'
            exit 1
          fi

          res=$(echo "$response" | jq 'has("commit")')
          if [ "$res" != "true" ]; then
            echo 'Grafana database healthcheck returned the wrong json!!'
            exit 1
          fi

          curl https://hc-ping.com/dd0d1722-fa2d-4bf3-94be-b37eb0652b37
        '';
      }
    )}";
  };

  systemd.timers.grafana-test = {
    description = "Test grafana timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "grafana-test.service" ];

    timerConfig = {
      # https://systemd.guru/#*-*-*%20*%3A00%2C30%3A00
      OnCalendar = "*-*-* *:00,30:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."ari.mudpuppy-cod.ts.net" = {
      forceSSL = true;
      sslCertificate = config.sops.secrets.ari-cert-grafana.path;
      sslCertificateKey = config.sops.secrets.ari-cert-key-grafana.path;

      locations."/grafana/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
