{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.tmux;
in {
  options.config.programs.tmux.enable = with lib; mkOption {
    type = types.bool;
    default = config.passthru.systemConfig.programs.tmux.enable;
    description = "Whether to enable tmux.";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.tmux ];

      file.".tmux.conf".text = ''
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set-option -g default-terminal tmux-256color
      '';
    };
  };
}
