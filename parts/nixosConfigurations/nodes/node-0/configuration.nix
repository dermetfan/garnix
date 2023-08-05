{ inputs, ... }:

{ config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "21.11";

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

  # samba TODO use `services.samba.openFirewall` instead once using recent enough nixpkgs
  networking.firewall = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };

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
        "root/nix" = {
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
        daemons = [ "2" "3" ];
        activate = {
          "2" = "6790b95b-8ef9-4a7a-a4d8-fe44cd4be8a1";
          "3" = "f15558c7-348c-4ec4-ac05-62dffbcea8b6";
        };
        openFirewall = true;
      };
      client.enable = true;
    };

    samba = {
      enable = true;
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

  bootstrap.secrets.initrd_ssh_host_ed25519_key.path = null;

  boot = {
    zfs.unlockEncryptedPoolsViaSSH = {
      enable = true;
      hostKeys = [
        config.bootstrap.secrets.initrd_ssh_host_ed25519_key.cleartext
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
