{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.environments.iog;
in {
  options.profiles.dermetfan.environments.iog = with lib; {
    enable = mkEnableOption "IOG" // {
      default = nixosConfig.profiles.iog.enable or false;
    };
    reposDir = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/projects/development/IOHK";
    };
  };

  config.programs = {
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

    fish.shellAbbrs.nix-iog = "nix --extra-substituters 'https://hydra.iohk.io https://hydra.p42.at'";
  };
}
