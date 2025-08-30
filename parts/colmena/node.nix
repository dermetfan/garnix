{ config, moduleWithSystem, ... } @ parts:

moduleWithSystem ({ system, ... }: { config, lib, pkgs, ... }: {
  options.nix.buildMachine = lib.mkOption {
    type = lib.types.attrs;
    default = {
      maxJobs = config.nix.settings.max-jobs;
      inherit system;
    };
  };

  config = {
    networking.domain = "dermetfan.net";

    profiles = {
      common.enable = true;

      cluster.node.peers = lib.pipe ./nodes [
        builtins.readDir
        builtins.attrNames
        (map (name: parts.config.flake.nixosConfigurations.${name}.config))
        (builtins.filter (peer: peer.networking.hostName != config.networking.hostName))
      ];
    };

    nix = {
      gc.automatic = true;
      optimise.automatic = true;
    };

    services.openssh.settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
})
