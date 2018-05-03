{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.tmux;
in {
  options       .programs.tmux.enable = lib.mkEnableOption "tmux";
  options.config.programs.tmux.enable = with lib; mkOption {
    type = types.bool;
    default =
      config                      .programs.tmux.enable or
      config.passthru.systemConfig.programs.tmux.enable;
    defaultText = "<option>programs.tmux.enable</option> or <option>passthru.systemConfig.programs.tmux.enable</option>";
    description = "Whether to configure tmux.";
  };

  config.home.packages = lib.optional config.programs.tmux.enable pkgs.tmux;
  config.home.file = lib.mkIf cfg.enable {
    ".tmux.conf".text = ''
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g default-terminal tmux-256color
    '';
  };
}
