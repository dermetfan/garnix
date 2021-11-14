{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.iog;
in {
  options.profiles.iog = with lib; {
    enable = mkEnableOption "IOG";
    reposDir = mkOption {
      type = types.path;
      default = "${config.misc.data.path}/projects/development/IOHK";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      git.includes = [
        {
          condition = "gitdir:${cfg.reposDir}/";
          contents = {
            user = {
              email = "robin.stumm@iohk.io";
              signingkey = "D00F363866377AD9";
            };
            commit.gpgSign = true;
          };
        }
      ];

      fish.shellAbbrs.nix-iog = "nix --extra-substituters 'https://hydra.iohk.io https://hydra.mantis.ist https://hydra.p42.at'";
    };
  };
}
