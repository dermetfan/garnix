{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.tmux;
in {
  options.profiles.dermetfan.programs.tmux.enable = lib.mkEnableOption "tmux" // {
    default =
      config            .programs.tmux.enable or
      config.nixosConfig.programs.tmux.enable or false;
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      sensibleOnTop = false;
      clock24 = true;
      baseIndex = 1;
      escapeTime = 0;
      prefix = "M-e";
      keyMode = "vi";
      terminal = "tmux-256color";
      extraConfig = ''
        set-option -ga terminal-features ',*alacritty*:256'
        set-option -ga terminal-features ',*alacritty*:RGB'
        set-option -g status-keys emacs
        set-option -g focus-events on
        set-option -g display-time 4000

        bind-key t clock-mode
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
        { plugin = yank; }
        { plugin = jump; }
        { plugin = sidebar; }
        { plugin = gruvbox; }
        { plugin = sessionist; }
      ];
    };
  };
}
