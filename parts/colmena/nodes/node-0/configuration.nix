{ inputs, ... }:

{ name, config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "24.11";

  environment.persistence."/state".files = map (key: key.path) config.services.openssh.hostKeys;

  age = {
    # https://github.com/ryantm/agenix/issues/45
    identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;
  };

  profiles = {
    afraid-freedns.enable = true;
    yggdrasil.enable = true;
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

  users = {
    # Setting up zfs permissions needs to be done manually:
    # `zfs allow -u znapzend mount,create,destroy,receive tank`
    users.znapzend = {
      isSystemUser = true;
      # Separate group to make sure that the user does not
      # get any unintended permissions via its group.
      group = config.users.groups.znapzend.name;
      shell = pkgs.bash;
      openssh.authorizedKeys.keyFiles = [
        ../../../../secrets/hosts/node-3/ssh_host_ed25519_key.pub
      ];
    };

    groups.znapzend = {};
  };

  boot = {
    zfs = {
      extraPools = [ "tank" ];

      unlockEncryptedPoolsViaSSH = {
        enable = true;
        hostKeys = [
          "${toString <secrets>}/hosts/${name}/initrd_ssh_host_ed25519_key"
        ];
      };
    };

    initrd = {
      network.ssh.port = 2222;

      postResumeCommands = lib.mkAfter ''
        zfs rollback -r root/root@blank
        zfs rollback -r root/home@blank
      '';
    };
  };
}
