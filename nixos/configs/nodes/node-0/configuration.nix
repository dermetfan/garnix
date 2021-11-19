{ pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  system.stateVersion = "21.05";

  profiles = {
    afraid-freedns.enable = true;
    nextcloud.enable = true;
  };

  services = {
    syncthing.enable = true;
    yggdrasil.publicPeers.germany.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kakoune
    ranger
    htop
  ];
}
