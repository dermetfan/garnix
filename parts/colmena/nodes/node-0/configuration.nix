{ inputs, ... }:

{ config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "23.05";

  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys;
    directories = [
      "/var/lib/ceph"
    ];
  };

  age = {
    # https://github.com/ryantm/agenix/issues/45
    identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

    secrets."ceph.client.mutmetfan.keyring" = {
      file = ../../../../secrets/services/ceph.client.mutmetfan.keyring.age;
      path = "/etc/ceph/ceph.client.mutmetfan.keyring";
      owner = config.users.users.ceph.name;
      group = config.users.users.ceph.group;
    };
  };

  profiles.afraid-freedns.enable = true;

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    znapzend = {
      pure = true;
      zetup = let
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
      in {
        "root/root" = {
          inherit timestampFormat recursive;
          plan = planFew;
        };
        "root/state" = {
          inherit timestampFormat recursive;
          plan = planMany;
        };
        "root/home" = {
          inherit timestampFormat recursive;
          plan = planMany;
        };
      };
    };

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
      osd = {
        enable = true;
        daemons = [ "3" ];
        activate."3" = "f15558c7-348c-4ec4-ac05-62dffbcea8b6";
        openFirewall = true;
      };
      client.enable = true;
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

  boot = {
    zfs.unlockEncryptedPoolsViaSSH = {
      enable = true;
      hostKeys = [
        "${toString <secrets>}/hosts/node-0/initrd_ssh_host_ed25519_key"
      ];
    };

    initrd = {
      network.ssh.port = 2222;

      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r root/root@blank
        zfs rollback -r root/home@blank
      '';
    };
  };
}
