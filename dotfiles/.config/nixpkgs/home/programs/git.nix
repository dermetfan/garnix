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
    delta.enable = true;

    userName = "Robin Stumm";
    userEmail = "serverkorken@gmail.com";

    aliases = {
      st = "status -s";
      lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium HEAD";
      co = "checkout";
      ci = "commit";
      spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
    };

    extraConfig = {
      status.submoduleSummary = true;
      diff.submodule = "log";
      delta.features = "gruvbox-dark";
    };
  };
}
