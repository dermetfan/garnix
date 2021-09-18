{ self, config, lib, ... }:

let
  cfg = config.services.ssmtp;
in {
  imports = [ ../../imports/age.nix ];

  config = lib.mkIf cfg.enable {
    age.secrets.ssmtp.file = ../../../secrets/ssmtp.age;

    services.ssmtp = {
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
