{ self, config, lib, pkgs, ... }:

{
  options.nix.buildMachine = with lib; mkOption {
    type = types.attrs;
    default = {
      inherit (config.nix) maxJobs;
      inherit (pkgs) system;
    };
  };

  config = {
    profiles = {
      default.enable = true;
      yggdrasil.enable = true;
    };

    networking = {
      domain = "dermetfan.net";
      useDHCP = false;
    };

    services = {
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
      };

      ceph.global = {
        fsid = "efec54b4-7ee8-479d-ba1c-34c5eb766dfa";
      } // lib.optionalAttrs config.services.ceph.mon.enable (let
        monInitialHosts = with self.nixosConfigurations; [ node-2 ];
      in {
        monInitialMembers = builtins.concatStringsSep "," (
          builtins.concatMap
            (h: h.config.services.ceph.mon.daemons)
            monInitialHosts
        );
        monHost = lib.concatMapStringsSep ","
          (host: "[${host.config.profiles.yggdrasil.ip}]")
          monInitialHosts;
      });
    };

    nix = {
      gc.automatic = true;
      optimise.automatic = true;
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
}
