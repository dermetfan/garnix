{ config, lib, ... }:

let
  cfg = config.services.minecraft-server;
in {
  options.services.minecraft-server.domain = with lib; mkOption {
    type = types.str;
    default = "minecraft.${config.networking.domain}";
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      eula = true;
      openFirewall = true;
    };

    networking.firewall.allowedTCPPorts =
      lib.optional cfg.openFirewall 25575; # RCON

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/resourcepacks/".alias = "${cfg.dataDir}/resourcepacks/";
      };
    };
  };
}
