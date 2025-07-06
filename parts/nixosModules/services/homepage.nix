{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.services.homepage;
in {
  options.services.homepage = with lib; {
    enable = mkEnableOption "homepage";
    package = mkOption {
      type = types.package;
      default = inputs.dermetfan-blog.defaultPackage.${pkgs.system}.overrideArgs (old: {
        extraConf.data.secrets.github.personalAccessToken = builtins.extraBuiltins.readSecret ../../../secrets/services/github.age;
      });
    };
    domain = mkOption {
      type = types.str;
      default = config.networking.domain;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        enableACME = true;
        addSSL = true;
        serverAliases = [ "www.${cfg.domain}" ];
        root = cfg.package;
      };
    };
  };
}
