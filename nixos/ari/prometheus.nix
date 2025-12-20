{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://ari.mudpuppy-cod.ts.net/prometheus";
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

    virtualHosts."ari.mudpuppy-cod.ts.net" = {
      locations."/prometheus" = {
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

          curl --fail https://ari.mudpuppy-cod.ts.net/prometheus/-/healthy
          curl --fail https://ari.mudpuppy-cod.ts.net/prometheus/-/ready

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
