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

        jix.argocd = {
          targetRevision = "e175c71b696752df431c2b313bd406731e7e149f";

          sources = [
            "k8s/attic"
            "k8s/argocd-server"
            "k8s/cert-manager"
            "k8s/github-runners"
            "k8s/ingress"
            "k8s/k8s-dashboard"
            "k8s/longhorn"
          ];
        };

        networking.firewall.enable = false;

        services = {
          openiscsi = {
            enable = true;
            name = "iqn.2025-01.cafe.jessie.iscsi:ari";
          };

          # kuwubernetes
          kubernetes = {
            masterAddress = config.networking.hostName;
            apiserver.allowPrivileged = true;

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
