{ pkgs, ... }:
{
  services = {
    headscale = {
      enable = true;
      settings = {
        server_url = "https://headscale.jessie.cafe";
        dns.magic_dns = false;
        dns.override_local_dns = false;
      };
    };

    nginx = {
      enable = true;
      virtualHosts."headscale.jessie.cafe" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jess@jessie.cafe";
  };

  environment.systemPackages = [ pkgs.headscale ];
}
