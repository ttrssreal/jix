{ lib, config, ... }:
{
  options.jix.pipewire.enable = lib.mkEnableOption "pipewire";

  config = lib.mkIf config.jix.pipewire.enable {
    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      # emulating these ones
      pulse.enable = true;
      jack.enable = true;
    };

    # lets pipewire ask for realtime scheduling
    security.rtkit.enable = true;
  };
}
