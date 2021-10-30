{ pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  system.stateVersion = "21.05";

  profiles = {
    default.enable = true;
    roundcube.enable = true;
    minecraft-server.enable = true;
    ssmtp.enable = true;
    hydra.enable = true;
    nextcloud.enable = true;
  };

  services = {
    afraid-freedns = {
      enable = true;
      ip4Tokens = [];
    };

    syncthing.enable = true;
    roundcube.config.enigma_pgp_homedir = "/data/roundcube/enigma";
    homepage.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kakoune
    ranger
    htop
  ];
}
