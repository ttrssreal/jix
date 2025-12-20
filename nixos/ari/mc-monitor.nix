{ pkgs, lib, ... }:
{
  systemd.services.mc-monitor = {
    description = "Minecraft server prometheus exporter";

    serviceConfig = {
      Environment = [
        "EXPORT_SERVERS=127.0.0.1"
        "DEBUG=true"
      ];
      ExecStart = "${lib.getExe pkgs.mc-monitor} export-for-prometheus";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
