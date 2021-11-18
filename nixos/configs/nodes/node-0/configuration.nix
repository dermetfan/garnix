{ pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  system.stateVersion = "21.05";

  profiles = {
    afraid-freedns.enable = true;
    roundcube.enable = true;
    minecraft-server.enable = true;
    ssmtp.enable = true;
    hydra.enable = true;
    nextcloud.enable = true;
  };

  services = {
    syncthing.enable = true;
    roundcube.config.enigma_pgp_homedir = "/data/roundcube/enigma";
    homepage.enable = true;

    yggdrasil.config.Peers = [
      "tcp://94.130.203.208:5999"
      "tcp://bunkertreff.ddns.net:5454"
      "tcp://phrl42.ydns.eu:8842"
      "tcp://ygg.mkg20001.io:80"
      "tcp://yugudorashiru.de:80"
    ];
  };

  environment.systemPackages = with pkgs; [
    kakoune
    ranger
    htop
  ];
}
