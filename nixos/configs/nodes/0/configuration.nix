{ pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  services = {
    afraid-freedns = {
      enable = true;
      ip4Tokens = [];
    };

    syncthing.enable = true;
    hydra.enable = true;
    minecraft-server.enable = true;
    nextcloud.enable = true;
    roundcube = {
      enable = true;
      config.enigma_pgp_homedir = "/data/roundcube/enigma";
    };
    ssmtp.enable = true;
    homepage.enable = true;
  };

  environment.systemPackages = with pkgs; [
    tmux
    kakoune
    ranger
    htop
  ];
}
