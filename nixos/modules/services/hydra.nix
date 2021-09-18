{ config, lib, pkgs, ... }:

let
  cfg = config.services.hydra;
in {
  options.services.hydra.domain = with lib; mkOption {
    type = types.str;
    default = "hydra.${config.networking.domain}";
  };

  config = lib.mkIf cfg.enable {
    services = {
      hydra = {
        hydraURL = "https://${cfg.domain}";
        notificationSender = "hydra@${cfg.domain}";
        buildMachinesFiles = [];
        useSubstitutes = true;
        smtpHost = "127.0.0.1";
      };

      ssmtp.enable = true;

      nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = let
          # nginx does not understand * for all interfaces
          listenHost = if config.services.hydra.listenHost == "*"
            then "0.0.0.0"
            else config.services.hydra.listenHost;
        in "http://${listenHost}:${toString config.services.hydra.port}";
      };
    };

    systemd.services = {
      hydra-server      .path = [ pkgs.ssmtp ];
      hydra-queue-runner.path = [ pkgs.ssmtp ];
    };
  };
}
