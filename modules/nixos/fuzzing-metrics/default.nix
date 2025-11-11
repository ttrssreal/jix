{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.jix.fuzzing-metrics.enable = lib.mkEnableOption "fuzzing metrics exporters";

  config = lib.mkIf config.jix.fuzzing-metrics.enable {
    systemd.services.statsd-exporter = {
      description = "Converts statsd metrics to prometheus metrics";
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          lib.flatten [
            "${lib.getExe pkgs.prometheus-statsd-exporter}"
            "--statsd.mapping-config=${pkgs.writeText "" ''
              mappings:
                - match: "fuzzing.*"
                  name: "fuzzing"
                  labels:
                      type: "$1"
            ''}"
          ]
        );
      };

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.node-exporter = {
      description = "Exports node metrics to prometheus";
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.prometheus-node-exporter}";
      };

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
