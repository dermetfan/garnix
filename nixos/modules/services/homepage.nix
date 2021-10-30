{ config, lib, pkgs, ... }:

let
  cfg = config.services.homepage;
in {
  options.services.homepage = with lib; {
    enable = mkEnableOption "homepage";
    package = mkOption {
      type = types.package;
      default = pkgs.dermetfan-blog;
    };
    domain = mkOption {
      type = types.str;
      default = config.networking.domain;
    };
  };

  config.services.nginx = lib.mkIf cfg.enable {
    enable = true;
    virtualHosts.${cfg.domain} = {
      enableACME = true;
      addSSL = true;
      serverAliases = [ "www.${cfg.domain}" ];
      root = cfg.package;
    };
  };
}
