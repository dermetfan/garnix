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

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      sensibleOnTop = false;
      clock24 = true;
      escapeTime = 0;
      extraConfig = ''
        set-option -ga terminal-overrides ',xterm-256color:Tc'
        set-option -g default-terminal tmux-256color
        set-option -g status-keys emacs
        set-option -g focus-events on
        set-option -g display-time 4000

        bind-key [ run-shell ${
          pkgs.stdenv.mkDerivation {
            name = "tmux-kak-copy-mode";
            src = pkgs.fetchFromGitHub {
              owner = "jbomanson";
              repo = "tmux-kak-copy-mode";
              rev = "fc41526cb8d4ad798b4165cae049e9f5e2fa8d3b";
              sha256 = "0iryzny1h6aawslzxk1203xb2fn0bnqx6857840mz2dwsjfgqdgx";
            };
            installPhase = ''
              mkdir -p $out/bin
              install -m 755 -t $out/bin bin/*
            '';
          }
        }/bin/tmux-kak-copy-mode
      '';

      tmuxp.enable = true;
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
        { plugin = gruvbox; }
      ];
    };
  };
}
