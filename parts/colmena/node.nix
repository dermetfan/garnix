{ config, moduleWithSystem, ... } @ parts:

moduleWithSystem ({ system, ... }: { nodes, config, lib, pkgs, ... }: {
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
      text = lib.readFile "${toString <secrets>}/hosts/${config.networking.hostName}/${name}";
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

    programs.ssh.knownHosts = lib.listToAttrs (
      lib.filter
      (knownHost: knownHost != null)
      (lib.forEach config.profiles.cluster.node.peers (peerConfig: let
        publicKeyFile = ../../secrets/hosts/${peerConfig.networking.hostName}/ssh_host_ed25519_key.pub;
      in
        if lib.pathExists publicKeyFile
        then {
          name = peerConfig.networking.hostName;
          value = {
            extraHostNames = [
              peerConfig.networking.hostName
              "${peerConfig.networking.hostName}.hosts.${peerConfig.networking.domain}"
            ];
            inherit publicKeyFile;
          };
        }
        else null
      ))
    );

    services.openssh.settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/deployer_ssh_ed25519_key.pub
    ];
  };
})
