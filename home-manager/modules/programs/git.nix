{ config, lib, ... }:

let
  cfg = config.config.programs.git;
in {
  options.config.programs.git.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.git.enable;
    defaultText = "<option>programs.git.enable</option>";
    description = "Whether to configure git.";
  };

  config.programs.git = lib.mkIf cfg.enable {
    delta = {
      enable = true;
      options.syntax-theme = "gruvbox-dark";
    };

    userName = "Robin Stumm";
    userEmail = "serverkorken@gmail.com";

    aliases = {
      st = "status --short";
      lg = "log --graph --decorate --abbrev-commit --pretty=medium";
      co = "checkout";
      ci = "commit";
      spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
    };

    extraConfig = {
      status.submoduleSummary = true;
      diff.submodule = "log";
    };
  };
}
