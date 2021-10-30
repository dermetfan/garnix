{ config, lib, pkgs, ... }:

{
  imports = [ node/bootstrap.nix ];

  options.nix.buildMachine = with lib; mkOption {
    type = types.attrs;
    default = {
      inherit (config.nix) maxJobs;
      inherit (pkgs) system;
    };
  };

  config = {
    networking = {
      domain = "dermetfan.net";
      useDHCP = false;
    };

    services = {
      "1.1.1.1".enable = true;
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
        hostKeys = [
          rec { type = "ed25519"; path = "/etc/ssh/ssh_host_${type}_key"; }
        ];
      };
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
