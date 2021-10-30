{
  # static network config from Hetzner's admin interface
  networking = {
    useDHCP = false;

    interfaces.eth0 = {
      ipv4.addresses = [ {
        address = "46.4.60.203";
        prefixLength = 26;
      } ];
      ipv6.addresses = [ {
        address = "2a01:4f8:140:215f::";
        prefixLength = 64;
      } ];
    };

    defaultGateway = "46.4.60.193";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
  };
}
