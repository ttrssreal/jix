{
  jix.nixos.ari.modules = [
    (
      {
        config,
        ...
      }:
      {
        imports = [
          ./argocd
        ];

        jix.argocd.targetRevision = "73c33e78b938258628355c2d01547ab3d6572934";
        networking.firewall.enable = false;

        services = {
          # kuwubernetes
          kubernetes = {
            masterAddress = config.networking.hostName;

            roles = [
              "master"
              "node"
            ];
          };
        };

      }
    )
  ];

  # fix certmgr restart looping kube services
  perSystem.jix.overlays = [
    (_: prev: {
      certmgr = prev.certmgr.overrideAttrs {
        patches = [
          ./001-fix-certmgr-hostname-checks.patch
        ];
      };
    })
  ];
}
