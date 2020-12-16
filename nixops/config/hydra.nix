{ config, lib, pkgs, ... }:

{
  services = {
    hydra = {
      hydraURL = "https://hydra.${config.passthru.domain}";
      notificationSender = "hydra@${config.passthru.domain}";
      buildMachinesFiles = [];
      useSubstitutes = true;
      smtpHost = "127.0.0.1";
    };

    ssmtp.enable = lib.mkIf config.services.hydra.enable true;

    nginx.virtualHosts = lib.mkIf config.services.hydra.enable {
      "hydra.${config.passthru.domain}" = config.passthru."nginx.virtualHosts.withSSL" {
        forceSSL = true;
        locations."/".proxyPass = let
          # nginx does not understand * for all interfaces
          listenHost = if config.services.hydra.listenHost == "*"
            then "0.0.0.0"
            else config.services.hydra.listenHost;
        in "http://${listenHost}:${toString config.services.hydra.port}";
      };
    };
  };

  systemd.services = lib.mkIf config.services.hydra.enable {
    hydra-server.path       = [ pkgs.ssmtp ];
    hydra-queue-runner.path = [ pkgs.ssmtp ];
  };
}
