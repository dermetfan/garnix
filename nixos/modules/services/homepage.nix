{ self, config, lib, pkgs, ... }:

let
  cfg = config.services.homepage;
in {
  options.services.homepage = with lib; {
    enable = mkEnableOption "homepage";
    package = mkOption {
      type = types.package;
      default = self.inputs.dermetfan-blog.defaultPackage.${pkgs.system}.overrideArgs (old: {
        extraConf.data.secrets.github.personalAccessToken = builtins.readFile config.bootstrap.secrets.github-token.cleartext;
      });
    };
    domain = mkOption {
      type = types.str;
      default = config.networking.domain;
    };
  };

  config = lib.mkIf cfg.enable {
    bootstrap.secrets.github-token = {
      file = "${toString <secrets>}/services/github";
      path = null;
    };

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
