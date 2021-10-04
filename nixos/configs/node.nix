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
    networking = {
      domain = "dermetfan.net";
      useDHCP = false;
    };

    services = {
      "1.1.1.1".enable = true;
      openssh = {
        passwordAuthentication = false;
        challengeResponseAuthentication = false;
      };
    };

    nix = {
      gc.automatic = true;
      optimise.automatic = true;
    };
  };
}
