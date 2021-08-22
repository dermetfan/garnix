{ config, lib, pkgs, ... }:

let
  cfg = config.services.homepage;
in {
  options.services.homepage = with lib; {
    enable = mkEnableOption "homepage";
    package = mkOption {
      type = types.package;
      default = pkgs.dermetfan-homepage;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx.virtualHosts = lib.mkIf config.services.hydra.enable {
        "${config.passthru.domain}" = config.passthru."nginx.virtualHosts.withSSL" {
          addSSL = true;
          serverAliases = [ "www.${config.passthru.domain}" ];
          root = cfg.package;
        };
      };
    };
  };
}
