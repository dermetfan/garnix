{ config, lib, ... }:

let
  cfg = config.profiles.yggdrasil;

  secret = file:
    ../../../secrets/hosts/${config.networking.hostName}/yggdrasil/${file};
in {
  imports = [ ../../imports/age.nix ];

  options.profiles.yggdrasil = {
    enable = lib.mkEnableOption "yggdrasil node";
    ip = with lib; mkOption {
      readOnly = true;
      type = types.str;
      default = fileContents (secret "ip");
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."yggdrasil.conf".file = secret "keys.conf.age";

    services.yggdrasil = {
      enable = true;
      configFile = config.age.secrets."yggdrasil.conf".path;
    };

    networking.hosts.${cfg.ip} = lib.mkDefault [
      config.networking.fqdn
      config.networking.hostName
    ];
  };
}
