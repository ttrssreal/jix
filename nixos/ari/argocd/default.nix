# installed via realizing a modified <argocd>/manifests/install.yaml.

{ lib, pkgs, ... }:
let
  readYAML = pkgs.callPackage ./read-yaml.nix { };
  toFile = builtins.toFile "argo-bootstrap-manifest";
  patchResource =
    resource: name:
    lib.optionalAttrs (resource.metadata.labels."app.kubernetes.io/name" or null == name);

  argo-cd = pkgs.fetchFromGitHub {
    owner = "argoproj";
    repo = "argo-cd";
    rev = "4471603de2a8f3e7e0bdfbd9d487468b6b20a354";
    hash = "sha256-NzMMzlLxGuPSCX2JiwRtWnEhS84Czm4O3a3E9jgBcU8=";
  };

  # resource definitions

  argoCdNamespace = {
    apiVersion = "v1";
    kind = "Namespace";
    metadata.name = "argocd";
  };

  argoRoleBinding = {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "ClusterRoleBinding";

    metadata = {
      name = "argo-cluster-admin-binding";
    };

    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "ClusterRole";
      name = "cluster-admin";
    };

    # https://github.com/kubernetes/kubernetes/issues/44703
    subjects =
      map
        (name: {
          apiGroup = "";
          kind = "ServiceAccount";
          namespace = "argocd";
          inherit name;
        })
        [
          # kubectl get serviceaccounts -n argocd
          "argocd-application-controller"
          "argocd-applicationset-controller"
          "argocd-dex-server"
          "argocd-notifications-controller"
          "argocd-redis"
          "argocd-repo-server"
          "argocd-server"
        ];
  };

  # "patches"

  configMap = {
    data."application.resourceTrackingMethod" = "annotation+label";
  };

  commandParamsConfigMap = {
    data."application.namespaces" = "*";
  };
in
{
  imports = [
    ./app.nix
  ];

  services.kubernetes.addonManager = {
    bootstrapAddons = {
      inherit argoCdNamespace argoRoleBinding;

      argocdInstall = {
        apiVersion = "v1";
        # https://kubernetes.io/docs/reference/using-api/api-concepts/#collections
        kind = "List";

        items =
          # readYAML will only parse single documents, so split out the multi-document
          # manifest into individual documents and give them one-by-one to readYAML
          # (IFD hell...)
          lib.pipe "${argo-cd}/manifests/install.yaml" [
            lib.readFile
            (lib.splitString "---")
            (map toFile)
            (map readYAML)
            (map (
              resource:
              lib.recursiveUpdate (
                {
                  metadata.namespace = argoCdNamespace.metadata.name;
                }
                // patchResource resource "argocd-cm" configMap
                // patchResource resource "argocd-cmd-params-cm" commandParamsConfigMap
              ) resource
            ))
          ];
      };
    };
  };
}
