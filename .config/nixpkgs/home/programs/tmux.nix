{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.tmux;
in {
  options.config.programs.tmux.enable = with lib; mkOption {
    type = types.bool;
    default =
      config                      .programs.tmux.enable or
      config.passthru.systemConfig.programs.tmux.enable;
    defaultText = "<option>programs.tmux.enable</option> or <option>passthru.systemConfig.programs.tmux.enable</option>";
    description = "Whether to configure tmux.";
  };

  config.programs.tmux = lib.mkIf cfg.enable {
    sensibleOnTop = false;
    extraConfig = ''
      set-option -ga terminal-overrides ',xterm-256color:Tc'
      set-option -g default-terminal tmux-256color
      set-option -g status-keys emacs
      set-option -g focus-events on
      set-option -g display-time 4000
      set-option -s escape-time 0
    '';

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-processes 'micro ~ranger ~"nixos-container root-login" ~"nixos-container run"'
          set -g @resurrect-save-shell-history on
          set -g @resurrect-capture-pane-contents on
        '';
      }
      { plugin = copycat; }
      { plugin = sidebar; }
      { plugin = yank; }
    ];
  };
}
