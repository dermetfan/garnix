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
  };

  # XXX Hack: We just want to decrypt it so we can use it below.
  bootstrap.secrets.initrd_ssh_host_ed25519_key.path = "/dev/null";

  boot = {
    kernelParams = [
      # https://nixos.wiki/wiki/NixOS_on_ZFS#Known_issues
      # https://github.com/openzfs/zfs/issues/260
      "nohibernate"
    ];

    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = map (p: pkgs.writeText "ssh_host_key" (builtins.readFile p)) [
            ../../../../secrets/hosts/nodes/2/initrd_ssh_host_ed25519_key
          ];
        };

        postCommands = ''
          echo 'zfs load-key -a; killall zfs' >> /root/.profile
        '';
      };

      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r root/root@blank
        zfs rollback -r root/home@blank
      '';
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/98100
  system.extraDependencies = config.boot.initrd.network.ssh.hostKeys;
}
