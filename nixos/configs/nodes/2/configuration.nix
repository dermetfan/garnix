{ self, config, lib, pkgs, ... }:

{
  imports = [
    ../../../imports/age.nix
    self.inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "21.11";

  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys;
    directories = [
      "/var/lib/acme"
      "/var/lib/ceph"
    ];
  };

  age = {
    # https://github.com/ryantm/agenix/issues/45
    sshKeyPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

    secrets = {
      "ceph.client.admin.keyring" = {
        file = ../../../../secrets/services/ceph.client.admin.keyring.age;
        path = "/etc/ceph/ceph.client.admin.keyring";
        owner = config.users.users.ceph.name;
        group = config.users.users.ceph.group;
      };
      "ceph.client.node.keyring" = {
        file = ../../../../secrets/services/ceph.client.node.keyring.age;
        path = "/etc/ceph/ceph.client.node.keyring";
        owner = config.users.users.ceph.name;
        group = config.users.users.ceph.group;
      };
    };
  };

  services = {
    homepage.enable = true;

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

    yggdrasil.config.Peers = [
      "tcp://94.130.203.208:5999"
      "tcp://bunkertreff.ddns.net:5454"
      "tcp://phrl42.ydns.eu:8842"
      "tcp://ygg.mkg20001.io:80"
      "tcp://yugudorashiru.de:80"
    ];

    ceph = {
      enable = true;
      mon = {
        enable = true;
        daemons = [ "a" ];
      };
      mgr = {
        enable = true;
        daemons = [ "a" ];
      };
      mds = {
        enable = true;
        daemons = [ "a" ];
      };
      osd = {
        enable = true;
        daemons = [ "0" "1" ];
        activate = {
          "0" = "f3219584-f489-44ba-b923-6a3dbec9577a";
          "1" = "062c7642-3f10-4a4f-b86b-4d69805ae484";
        };
      };
      client.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # TODO fix original wrapper in nixpkgs
    # see https://github.com/NixOS/nixpkgs/issues/21748#issuecomment-271147560
    (pkgs.writers.writeBashBin "mount.fuse.ceph-fixed" ''
      export PATH=${pkgs.util-linux}/bin:"$PATH"
      exec -a "$0" ${ceph}/bin/mount.fuse.ceph "$@"
    '')
  ];

  systemd.mounts = [ rec {
    wantedBy = [ "ceph.target" ];
    partOf = wantedBy;
    after =
      map (id: "ceph-mon-${id}.service") config.services.ceph.mon.daemons ++
      map (id: "ceph-mds-${id}.service") config.services.ceph.mds.daemons ++
      map (id: "ceph-mgr-${id}.service") config.services.ceph.mgr.daemons;
    conflicts = [ "umount.target" ];
    type = "fuse.ceph-fixed";
    what = "none";
    where = "/cephfs";
    options = "ceph.id=node";
  } ];

  bootstrap.secrets.initrd_ssh_host_ed25519_key.path = null;

  boot = {
    kernelParams = [
      # https://nixos.wiki/wiki/NixOS_on_ZFS#Known_issues
      # https://github.com/openzfs/zfs/issues/260
      "nohibernate"
    ];

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
