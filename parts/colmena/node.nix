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
    deployment.keys.ssh_host_key = rec {
      name = "ssh_host_ed25519_key";
      text = builtins.extraBuiltins.readSecret ../../secrets/hosts/${config.networking.hostName}/${name}.age;
      destDir = "/etc/ssh";
      permissions = "0400";
    };

    networking.domain = "dermetfan.net";

    profiles = {
      common.enable = true;
      stylix.enable = lib.mkDefault true;

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
