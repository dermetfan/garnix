{ config, lib, ... }: {
  # static network config from Hetzner's admin interface
  # https://docs.hetzner.com/robot/dedicated-server/network/network-configuration-using-systemd-networkd
  networking = {
    useNetworkd = true;

    # https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers/
    nameservers = [
      "185.12.64.1"
      "185.12.64.2"
    ] ++ lib.optionals config.networking.enableIPv6 [
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
  };

  boot.initrd.systemd.network = {
    enable = true;
    networks = { inherit (config.systemd.network.networks) "10-mainif"; };
  };

  systemd.network = {
    enable = true;
    networks."10-mainif" = let
      ip4  = "176.9.143.248";
      gw4  = "176.9.143.225";
      ip6  = "2a01:4f8:160:21e2::";
      gw6  = "fe80::1";
    in {
      matchConfig.MACAddress = "30:85:a9:ee:25:fa";

      address = [ "${ip6}/64" ];
      gateway = [ gw4 gw6 ];

      addresses = [
        { Address = "${ip4}/32"; Peer = "${gw4}/32"; }
      ];

      networkConfig = {
        DHCP = "no";
        # Hetzner does not send RAs.
        IPv6AcceptRA = false;
        # Must be at least "ipv6" because the IPv6 gateway is only reachable via the link-local scope.
        LinkLocalAddressing = "ipv6";
      };

      linkConfig = {
        RequiredForOnline = "routable";
        RequiredFamilyForOnline = "ipv4";
      };
    };
  };
}
