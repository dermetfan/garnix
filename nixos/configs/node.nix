{ self, config, lib, ... }:

{
  options.nix.buildMachine = with lib; mkOption {
    type = types.attrs;
    default = {
      inherit (config.nix) maxJobs;
      inherit (pkgs) system;
    };
  };

  config = {
    networking.domain = "dermetfan.net";

    profiles = {
      common.enable = true;

      cluster = {
        node.peers = lib.pipe ./nodes [
          builtins.readDir
          builtins.attrNames
          (map (name: self.nixosConfigurations.${name}.config))
          (builtins.filter (peer: peer.networking.hostName != config.networking.hostName))
        ];

        ceph = {
          yggdrasil = true;
          monInitialHosts = with self.nixosConfigurations; [ node-2 node-0 node-3 ];
        };
      };
    };

    nix = {
      gc.automatic = true;
      optimise.automatic = true;
    };

    services = {
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
      };

      ceph.global.fsid = "efec54b4-7ee8-479d-ba1c-34c5eb766dfa";
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
}
