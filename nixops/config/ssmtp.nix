{ config, lib, ... }:

{
  services.ssmtp = {
    hostName = "smtp.gmail.com:587";
    root = "serverkorken@gmail.com";
    inherit (config.passthru) domain;
    authUser = "serverkorken@gmail.com";
    authPassFile = "/run/keys/ssmtp";
    useTLS = true;
    useSTARTTLS = true;
  };

  deployment.keys.ssmtp = lib.mkIf config.services.ssmtp.enable {
    keyFile = ../../keys/ssmtp;
  };
}
