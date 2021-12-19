{ pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  system.stateVersion = "21.05";

  profiles.afraid-freedns.enable = true;

  services = {
    syncthing.enable = true;

    yggdrasil.publicPeers.germany.enable = true;

    ceph = {
      enable = true;
      mon = {
        enable = true;
        daemons = [ "b" ];
        openFirewall = true;
      };
      mgr = {
        enable = true;
        daemons = [ "b" ];
        openFirewall = true;
      };
      mds = {
        enable = true;
        daemons = [ "b" ];
        openFirewall = true;
      };
    };
  };
}
