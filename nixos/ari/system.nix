{
  config,
  ...
}:
{
  imports = [
    ./argocd
  ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  jix.argocd.targetRevision = "73c33e78b938258628355c2d01547ab3d6572934";

  services = {
    openssh.enable = true;

    atticd = {
      enable = true;

      # FIXME: part of declarative secret management
      environmentFile = "/etc/atticd.env";

      settings = {
        listen = "[::]:8080";

        storage = {
          type = "s3";
          region = "us-west-002";
          bucket = "nix-cache-b5eea907c395";
          endpoint = "https://nix-cache-b5eea907c395.s3.us-west-002.backblazeb2.com";
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

    # kuwubernetes
    kubernetes = {
      masterAddress = config.networking.hostName;

      roles = [
        "master"
        "node"
      ];
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
