{ pkgs, ... }:
let
  endpoint = "flat.jessie.cafe";

  getDefaultRouteAttr = attrName: ''
    ${pkgs.iproute2}/bin/ip route | ${pkgs.gawk}/bin/awk '/default/ {for(i=1;i<=NF;i++) if($i=="${attrName}") print $(i+1)}'
  '';
in
{
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "192.168.50.3/24" ];

      # add a route so wireguard protocol packets use the normal transport
      # layer instead of going over wireguard
      preSetup = ''
        ENDPOINT_IP=$(${pkgs.bind.dnsutils}/bin/dig +short ${endpoint})
        ${pkgs.iproute2}/bin/ip route add $ENDPOINT_IP \
          via $(${getDefaultRouteAttr "via"}) \
          dev $(${getDefaultRouteAttr "dev"})
      '';

      postShutdown = ''
        ENDPOINT_IP=$(${pkgs.bind.dnsutils}/bin/dig +short ${endpoint})
        ${pkgs.iproute2}/bin/ip route delete $ENDPOINT_IP
      '';

      privateKeyFile = "/home/jess/.keys/wg/wgclient.key";

      peers = [
        {
          publicKey = "jAESPQHSNIJDjjm9ZMLLmS8OUEK/8+iPY8Dje3cxrFo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "${endpoint}:306";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
