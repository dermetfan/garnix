{ config, lib, pkgs, ... }:

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
      afraid-freedns.enable = true;
      yggdrasil.enable = true;
    };

    networking = {
      domain = "dermetfan.net";
      useDHCP = false;
    };

    services.openssh = {
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
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
