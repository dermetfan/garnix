{ config, lib, ... }:

let
  cfg = config.profiles.afraid-freedns;
in {
  imports = [ ../../imports/age.nix ];

  options.profiles.afraid-freedns = with lib; {
    enable = mkEnableOption "freedns.afraid.org";
    updateIp4 = mkEnableOption "update IPv4" // { default = true; };
    updateIp6 = mkEnableOption "update IPv6";
  };

  config = lib.mkIf cfg.enable {
    age.secrets."afraid-freedns-token".file = ../../../secrets/hosts/${config.networking.hostName}/freedns.age;

    services.afraid-freedns = {
      enable = true;
      ip4TokensFile = lib.mkIf cfg.updateIp4 config.age.secrets."afraid-freedns-token".path;
      ip6TokensFile = lib.mkIf cfg.updateIp6 config.age.secrets."afraid-freedns-token".path;
    };
  };
}
