{ config, lib, ... }:

{
  services.minecraft-server = {
    eula = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts =
    lib.optional (config.services.minecraft-server.enable && config.services.minecraft-server.openFirewall) 25575; # RCON

  services.nginx = lib.mkIf config.services.minecraft-server.enable {
    enable = true;
    virtualHosts = {
      "minecraft.${config.passthru.domain}" = config.passthru."nginx.virtualHosts.withSSL" {
        forceSSL = true;
        locations."/resourcepacks/".alias = "${config.services.minecraft-server.dataDir}/resourcepacks/";
      };
    };
  };
}
