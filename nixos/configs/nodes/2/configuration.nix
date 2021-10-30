{ self, config, lib, pkgs, ... }:

{
  imports = [
    ../../../imports/age.nix
    self.inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "21.11";

  profiles.default.enable = true;

  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys;
    directories = [
      "/var/lib/acme"
    ];
  };

  services = {
    homepage.enable = true;

    afraid-freedns = {
      enable = true;
      ip4Tokens = [];
    };

    zfs.autoScrub.enable = true;

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
  };

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
        ../../../../secrets/hosts/nodes/2/initrd_ssh_host_ed25519_key
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
