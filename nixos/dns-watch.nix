{ config, lib, ... }:

let
  cfg = config.config."dns.watch";
in {
  options.config."dns.watch".enable = lib.mkEnableOption "use dns.watch nameservers";

  config = lib.mkIf cfg.enable {
    networking.nameservers = [
      "84.200.69.80"
      "84.200.70.40"
    ];
  };
}
