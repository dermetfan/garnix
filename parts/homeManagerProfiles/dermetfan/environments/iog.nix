{ nixosConfig ? null, config, lib, ... }:

let
  cfg = config.profiles.dermetfan.environments.iog;
in {
  options.profiles.dermetfan.environments.iog = with lib; {
    enable = mkEnableOption "IOG" // {
      default = nixosConfig.profiles.iog.enable or false;
    };

    reposDir = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/projects/development/IOHK/repos";
    };

    gitSigningFormat = mkOption {
      type = types.enum ["gpg" "ssh"];
      default = "ssh";
    };
  };

  config = {
    programs = {
      git.includes = [
        {
          condition = "gitdir:${cfg.reposDir}/";
          contents = rec {
            user = {
              email = "robin.stumm@iohk.io";
              signingKey = {
                gpg = "D00F363866377AD9";
                ssh = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
              }.${cfg.gitSigningFormat};
            };
            commit.gpgSign = true;
            gpg = lib.mkIf (cfg.gitSigningFormat == "ssh") {
              format = "ssh";
              ssh.allowedSignersFile = user.signingKey;
            };
          };
        }
      ];

      gpg.enable = true;
    };

    services.gpg-agent.enable = true;
  };
}
