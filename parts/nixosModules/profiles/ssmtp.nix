{ inputs, ... }:

{ config, lib, ... }:

let
  cfg = config.profiles.ssmtp;
in {
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  options.profiles.ssmtp.enable = lib.mkEnableOption "ssmtp";

  config = lib.mkIf cfg.enable {
    age.secrets.ssmtp.file = ../../../secrets/services/ssmtp.age;

    services.ssmtp = {
      enable = true;
      hostName = "smtp.gmail.com:587";
      root = "serverkorken@gmail.com";
      inherit (config.networking) domain;
      authUser = "serverkorken@gmail.com";
      authPassFile = config.age.secrets.ssmtp.path;
      useTLS = true;
      useSTARTTLS = true;
    };
  };
}
