{
  pkgs,
  lib,
  config,
  ...
}:
{
  sops.secrets = {
    cert-prometheus = {
      owner = "nginx";
      key = "wildcard-app-cert";
    };

    cert-key-prometheus = {
      owner = "nginx";
      key = "wildcard-app-cert-key";
    };
  };

  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prometheus.app.jessie.cafe";
    port = 9001;

    exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };

    scrapeConfigs = [
      {
        job_name = "ari";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "healthcheck-io";
        scheme = "https";
        metrics_path = "/projects/f79d809f-4cba-428c-a159-d6168de83151/metrics/hcr_S8M4hOXDR9pCHcgsCtXDzCt1GsYp";
        static_configs = [
          {
            targets = [ "healthchecks.io" ];
          }
        ];
      }
      {
        job_name = "charlie-charlie-kirky-mc-server";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = [ "127.0.0.1:8080" ];
          }
        ];
      }
    ];
  };

  services.nginx = {
    enable = true;

    virtualHosts."prometheus.app.jessie.cafe" = {
      forceSSL = true;
      sslCertificate = config.sops.secrets.cert-prometheus.path;
      sslCertificateKey = config.sops.secrets.cert-key-prometheus.path;

      locations."/" = {
        proxyPass = "http://127.0.0.1:9001";
      };
    };
  };

  systemd.services.prometheus-test = {
    description = "Test prometheus";

    serviceConfig.ExecStart = "${lib.getExe (
      pkgs.writeShellApplication {
        name = "prometheus-test-exec-start";

        runtimeInputs = [
          pkgs.curl
        ];

        text = ''
          set -xeo pipefail

          curl --fail https://prometheus.app.jessie.cafe/-/healthy
          curl --fail https://prometheus.app.jessie.cafe/-/ready

          curl https://hc-ping.com/3a811a39-18c7-40ea-9039-a8a4d311b6b9
        '';
      }
    )}";
  };

  systemd.timers.prometheus-test = {
    description = "Test prometheus timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "prometheus-test.service" ];

    timerConfig = {
      # https://systemd.guru/#*-*-*%20*%3A00%2C30%3A00
      OnCalendar = "*-*-* *:00,30:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
