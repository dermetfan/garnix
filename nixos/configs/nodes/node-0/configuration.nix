{ config, pkgs, ... }:

{
  misc.data.enable = true; # XXX should this belong to hardware config?

  system.stateVersion = "21.05";

  age.secrets."ceph.client.mutmetfan.keyring" = {
    file = ../../../../secrets/services/ceph.client.mutmetfan.keyring.age;
    path = "/etc/ceph/ceph.client.mutmetfan.keyring";
    owner = config.users.users.ceph.name;
    group = config.users.users.ceph.group;
  };

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

    samba = {
      enable = true;
      openFirewall = true;
      extraConfig = ''
        server string = ${config.networking.hostName}
        netbios name = ${config.networking.hostName}
        guest account = nobody
        map to guest = bad user
      '';
      shares.mutmetfan = {
        path = "/mnt/cephfs/home/mutmetfan";
        browseable = "yes";
        writeable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  fileSystems."/mnt/cephfs/home/mutmetfan" = {
    fsType = "fuse.ceph-fixed";
    device = "none";
    options = [
      "nofail"
      "ceph.id=mutmetfan,ceph.client_mountpoint=/home/mutmetfan"
    ];
  };

  users.users.mutmetfan = {
    isNormalUser = true;
    createHome = false;
    useDefaultShell = false;
  };
}
