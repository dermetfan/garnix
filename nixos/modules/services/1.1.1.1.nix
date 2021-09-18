{ config, lib, ... }:

let
  cfg = config.services."1.1.1.1";
in {
  options.services."1.1.1.1".enable = lib.mkEnableOption "1.1.1.1 DNS by CloudFlare and APNIC";

  config = lib.mkIf cfg.enable {
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ] ++ lib.optionals config.networking.enableIPv6 [
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
}
