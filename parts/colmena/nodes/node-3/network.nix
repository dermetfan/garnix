{ config, lib, ... }: {
  # static network config from Hetzner's admin interface
  networking = {
    useDHCP = false;

    interfaces.eth0 = {
      ipv4.addresses = [ {
        address = "176.9.143.248";
        prefixLength = 27;
      } ];
      ipv6.addresses = [ {
        address = "2a01:4f8:160:21e2::";
        prefixLength = 64;
      } ];
    };

    defaultGateway = "176.9.143.225";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };

    # https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers/
    nameservers = [
      "185.12.64.1"
      "185.12.64.2"
    ] ++ lib.optionals config.networking.enableIPv6 [
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
  };
}
