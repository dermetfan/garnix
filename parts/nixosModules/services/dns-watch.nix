_:

{ config, lib, ... }:

let
  cfg = config.services."dns.watch";
in {
  options.services."dns.watch".enable = lib.mkEnableOption "dns.watch nameservers";

  config = lib.mkIf cfg.enable {
    networking.nameservers = [
      "84.200.69.80" # resolver1.dns.watch
      "84.200.70.40" # resolver2.dns.watch
    ] ++ lib.optionals config.networking.enableIPv6 [
      "2001:1608:10:25::1c04:b12f" # resolver1.dns.watch / resolver1v6.dns.watch
      "2001:1608:10:25::9249:d69b" # resolver2.dns.watch / resolver2v6.dns.watch
    ];
  };
}
