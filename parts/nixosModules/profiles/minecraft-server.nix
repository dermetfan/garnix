_:

{ config, lib, ... }:

let
  cfg = config.profiles.minecraft-server;
in {
  options.profiles.minecraft-server = with lib; {
    enable = mkEnableOption "minecraft-server";

    domain = mkOption {
      type = types.str;
      default = "minecraft.${config.networking.domain}";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      minecraft-server = {
        enable = true;
      };

      nginx = {
        enable = true;
        virtualHosts.${cfg.domain} = {
          enableACME = true;
          forceSSL = true;
          locations."/resourcepacks/".alias = "${cfg.dataDir}/resourcepacks/";
        };
      };
    };
  };
}
