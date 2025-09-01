{ self, options, nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.tmux;
in {
  imports = [
    self.inputs.tmux-which-key.homeManagerModules.default
  ];

  options.profiles.dermetfan.programs.tmux = {
    enable = lib.mkEnableOption "tmux" // {
      default =
        config     .programs.tmux.enable or
        nixosConfig.programs.tmux.enable or false;
    };

    remapMovement = lib.mkEnableOption ''
      a keymap that uses JKIL instead of HJKL,
      but for the Norman keyboard layout,
      so it is NIRO
    '' // {
      default = config.programs.tmux.keyMode == "vi";
    };
  };

  config.programs.tmux = {
    sensibleOnTop = false;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 5000;
    focusEvents = true;
    prefix = "M-e";
    keyMode = "vi";
    terminal = "tmux-256color";
    extraConfig = ''
      set-option -ga terminal-features ',xterm*:256'
      set-option -ga terminal-features ',xterm*:RGB'
      set-option -ga terminal-features ',*alacritty*:256'
      set-option -ga terminal-features ',*alacritty*:RGB'
      set-option -ga terminal-features ',*foot*:256'
      set-option -ga terminal-features ',*foot*:RGB'

      set-option -g status-keys emacs
      set-option -g display-time 4000
      set-option -g set-titles on
      set-option -g renumber-windows on

      bind-key -T prefix \" split-window -c '#{pane_current_path}'
      bind-key -T prefix % split-window -hc '#{pane_current_path}'
      bind-key -T prefix c new-window -c '#{pane_current_path}'

      bind-key -T prefix t clock-mode
      bind-key -T prefix \{ run-shell ${pkgs.tmuxPlugins.kak-copy-mode.rtp}
    '' + lib.optionalString cfg.remapMovement (
      assert cfg.remapMovement -> !config.programs.tmux.customPaneNavigationAndResize;
      ''
        # These might override other bindings.
        # I add no replacement bindings for them
        # as everything I care about should be in which-key.
        # The prefix keymap is just for quick access.

        # like i3/sway

        unbind-key -T prefix p
        unbind-key -T prefix n

        bind-key -T prefix n select-pane -L
        bind-key -T prefix o select-pane -R
        bind-key -T prefix r select-pane -U
        bind-key -T prefix i select-pane -D

        bind-key -T prefix N swap-pane -d -t '{left-of}'
        bind-key -T prefix O swap-pane -d -t '{right-of}'
        bind-key -T prefix R swap-pane -d -t '{up-of}'
        bind-key -T prefix I swap-pane -d -t '{down-of}'

        bind-key -T prefix -r C-n previous-window
        bind-key -T prefix -r C-o next-window

        bind-key -T prefix -r C-N swap-window -d -t '{previous}'
        bind-key -T prefix -r C-O swap-window -d -t '{next}'

        # alternative in case the terminal emulator has `C-{N,O}` bindings configured, as is common
        bind-key -T prefix -r C-M-n swap-window -d -t '{previous}'
        bind-key -T prefix -r C-M-o swap-window -d -t '{next}'

        bind-key -T prefix -r M-n resize-pane -L ${toString config.programs.tmux.resizeAmount}
        bind-key -T prefix -r M-o resize-pane -R ${toString config.programs.tmux.resizeAmount}
        bind-key -T prefix -r M-r resize-pane -U ${toString config.programs.tmux.resizeAmount}
        bind-key -T prefix -r M-i resize-pane -D ${toString config.programs.tmux.resizeAmount}

        bind-key -T prefix -r M-N resize-pane -L
        bind-key -T prefix -r M-O resize-pane -R
        bind-key -T prefix -r M-R resize-pane -U
        bind-key -T prefix -r M-I resize-pane -D

        bind-key -T prefix h split-window -h
        bind-key -T prefix H split-window -h -b
        bind-key -T prefix v split-window -v
        bind-key -T prefix V split-window -v -b

        # The key tables of any other mode than `copy-mode{,-vi}`
        # (so `{view,tree,client,buffer,options,clock}-mode`) are not configurable.
        # However, in these modes, the root key table is applied
        # and precedes the mode's own key table
        # so, using a condition, we can use it to override keys.
        # https://unix.stackexchange.com/questions/759401/is-there-a-way-to-customize-the-keys-in-tmuxs-choose-mode
        bind-key -T root n if-shell -F '#{pane_in_mode}' 'send-keys Left'  'send-keys n'
        bind-key -T root o if-shell -F '#{pane_in_mode}' 'send-keys Right' 'send-keys o'
        bind-key -T root r if-shell -F '#{pane_in_mode}' 'send-keys Up'    'send-keys r'
        bind-key -T root i if-shell -F '#{pane_in_mode}' 'send-keys Down'  'send-keys i'

        ## Make VI copy mode more like Kakoune.

        # Some bindings are already the default but let's be explicit and repeat them here for reference.
        # Those are marked with a trailing empty line comment `#`.
        #
        # In Kakoune, the shift key is used to extend the selection,
        # for which there is no equivalent concept in tmux.
        #
        # Also some alt key variants of bindings have no equivalent in tmux.
        #
        # That means we end up with multiple bindings for some movements.
        #
        # Let's keep the shift and alt variants of the bindings anyway
        # so that muscle memory from Kakoune still applies.

        # like normal mode

        bind-key -T copy-mode-vi n send-keys -X cursor-left
        bind-key -T copy-mode-vi o send-keys -X cursor-right
        bind-key -T copy-mode-vi r send-keys -X cursor-up
        bind-key -T copy-mode-vi i send-keys -X cursor-down

        bind-key -T copy-mode-vi   j send-keys -X search-again
        bind-key -T copy-mode-vi M-j send-keys -X search-reverse

        bind-key -T copy-mode-vi   W send-keys -X next-space #
        bind-key -T copy-mode-vi M-w send-keys -X next-space

        bind-key -T copy-mode-vi   E send-keys -X next-space-end #
        bind-key -T copy-mode-vi M-e send-keys -X next-space-end

        bind-key -T copy-mode-vi   B send-keys -X previous-space #
        bind-key -T copy-mode-vi   b send-keys -X previous-space
        # this should be `previous-space-end` but that command does not exist
        bind-key -T copy-mode-vi M-b send-keys -X previous-space

        bind-key -T copy-mode-vi   F command-prompt -1 -p '(jump backward)' { send-keys -X jump-backward '%%' } #
        bind-key -T copy-mode-vi M-f command-prompt -1 -p '(jump backward)' { send-keys -X jump-backward '%%' }

        bind-key -T copy-mode-vi   T command-prompt -1 -p '(jump to backward)' { send-keys -X jump-to-backward '%%' } #
        bind-key -T copy-mode-vi M-t command-prompt -1 -p '(jump to backward)' { send-keys -X jump-to-backward '%%' }

        bind-key -T copy-mode-vi   / command-prompt -T search -p '(search down)' { send-keys -X search-forward '%%' } #
        bind-key -T copy-mode-vi   ? command-prompt -T search -p '(search down)' { send-keys -X search-forward '%%' }
        bind-key -T copy-mode-vi M-/ command-prompt -T search -p '(search up)' { send-keys -X search-backward '%%' }
        bind-key -T copy-mode-vi M-? command-prompt -T search -p '(search up)' { send-keys -X search-backward '%%' }

        bind-key -T copy-mode-vi x send-keys -X select-line
        bind-key -T copy-mode-vi X send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi v send-keys -X set-mark
        bind-key -T copy-mode-vi   m send-keys -X next-matching-bracket
        bind-key -T copy-mode-vi M-m send-keys -X previous-matching-bracket

        # like goto mode

        bind-key -T copy-mode-vi T send-keys -X top-line
        bind-key -T copy-mode-vi C send-keys -X middle-line
        bind-key -T copy-mode-vi B send-keys -X bottom-line

        bind-key -T copy-mode-vi H send-keys -X start-of-line

        unbind-key -T copy-mode-vi ^
        bind-key -T copy-mode-vi h send-keys -X back-to-indentation

        # like view mode

        bind-key -T copy-mode-vi C-t send-keys -X scroll-top
        bind-key -T copy-mode-vi C-v send-keys -X scroll-middle
        bind-key -T copy-mode-vi C-b send-keys -X scroll-bottom

        bind-key -T copy-mode-vi R send-keys -X scroll-up
        bind-key -T copy-mode-vi I send-keys -X scroll-down
      ''
    );

    tmuxp.enable = true;

    tmux-which-key = {
      enable = true;
      settings = {
        inherit (options.programs.tmux.tmux-which-key.settings.default)
          title
          position
          command_alias_start_index;
        custom_variables = [];
        macros = [];
        keybindings = {
          prefix_table = "Space";
          root_table = "M-Space";
        };
        items = let
          close = {
            name = "⇩ Close Menu";
            key = config.programs.tmux.tmux-which-key.settings.keybindings.prefix_table;
            command = " ";
          };
        in [
          close
          { separator = true; }
          {
            name = "Pane ←";
            key = "n";
            command = "select-pane -L";
            transient = true;
          }
          {
            name = "Pane →";
            key = "o";
            command = "select-pane -R";
            transient = true;
          }
          {
            name = "Pane ↑";
            key = "r";
            command = "select-pane -U";
            transient = true;
          }
          {
            name = "Pane ↓";
            key = "i";
            command = "select-pane -D";
            transient = true;
          }
          {
            name = "Window ←";
            key = "M-n";
            command = "previous-window";
            transient = true;
          }
          {
            name = "Window →";
            key = "M-o";
            command = "next-window";
            transient = true;
          }
          { separator = true; }
          {
            name = "⇨ Buffers";
            key = "b";
            menu = [
              close
              { separator = true; }
              {
                name = "Choose";
                key = "b";
                command = "choose-buffer -Z";
              }
              {
                name = "Paste";
                key = "p";
                command = "paste-buffer -p";
              }
              {
                name = "Pop";
                key = "M-p";
                command = "paste-buffer -p -d";
              }
              {
                name = "Drop";
                key = "d";
                command = "delete-buffer";
              }
            ];
          }
          {
            name = "⇨ Panes";
            key = "p";
            menu = [
              close
              { separator = true; }
              {
                name = "Choose";
                key = "p";
                command = "display-panes -d 0";
              }
              {
                name = "Last";
                key = "l";
                command = "last-pane";
              }
              { separator = true; }
              {
                name = "Zoom";
                key = "z";
                command = "resize-pane -Z";
              }
              {
                name = "Break Out";
                key = "w";
                command = "break-pane";
              }
              {
                name = "Clear History";
                key = "h";
                command = ''confirm-before -p "Clear history of pane #P? (y/N)" "clear-history -H"'';
              }
              { separator = true; }
              {
                name = "Mark";
                key = "m";
                command = "select-pane -m";
              }
              {
                name = "Unmark";
                key = "M-m";
                command = "select-pane -M";
              }
              { separator = true; }
              {
                name = "Capture";
                key = "c";
                command = "capture-pane";
              }
              {
                name = "Kill";
                key =
                  if config.programs.tmux.disableConfirmationPrompt
                  then "K"
                  else "k";
                command =
                  if config.programs.tmux.disableConfirmationPrompt
                  then "kill-pane"
                  else ''confirm-before -p "Kill pane #P? (y/N)" kill-pane'';
              }
              { separator = true; }
              {
                name = "⇨ Resize";
                key = "r";
                menu = [
                  close
                  { separator = true; }
                  {
                    name = "Left";
                    key = "n";
                    command = "resize-pane -L ${toString config.programs.tmux.resizeAmount}";
                    transient = true;
                  }
                  {
                    name = "Right";
                    key = "o";
                    command = "resize-pane -R ${toString config.programs.tmux.resizeAmount}";
                    transient = true;
                  }
                  {
                    name = "Up";
                    key = "r";
                    command = "resize-pane -U ${toString config.programs.tmux.resizeAmount}";
                    transient = true;
                  }
                  {
                    name = "Down";
                    key = "i";
                    command = "resize-pane -D ${toString config.programs.tmux.resizeAmount}";
                    transient = true;
                  }
                  {
                    name = "Left (fine)";
                    key = "N";
                    command = "resize-pane -L";
                    transient = true;
                  }
                  {
                    name = "Right (fine)";
                    key = "O";
                    command = "resize-pane -R";
                    transient = true;
                  }
                  {
                    name = "Up (fine)";
                    key = "R";
                    command = "resize-pane -U";
                    transient = true;
                  }
                  {
                    name = "Down (fine)";
                    key = "I";
                    command = "resize-pane -D";
                    transient = true;
                  }
                ];
              }
              {
                name = "⇨ Swap Panes";
                key = "s";
                menu = [
                  close
                  { separator = true; }
                  {
                    name = "Left";
                    key = "n";
                    command = ''swap-pane -d -t "{left-of}"'';
                    transient = true;
                  }
                  {
                    name = "Right";
                    key = "o";
                    command = ''swap-pane -d -t "{right-of}"'';
                    transient = true;
                  }
                  {
                    name = "Up";
                    key = "r";
                    command = ''swap-pane -d -t "{up-of}"'';
                    transient = true;
                  }
                  {
                    name = "Down";
                    key = "i";
                    command = ''swap-pane -d -t "{down-of}"'';
                    transient = true;
                  }
                  { separator = true; }
                  {
                    name = "Marked";
                    key = "m";
                    command = "swap-pane";
                    transient = true;
                  }
                ];
              }
            ];
          }
          {
            name = "⇨ Windows";
            key = "w";
            menu = [
              close
              { separator = true; }
              {
                name = "Choose";
                key = "w";
                command = "choose-tree -Zw";
              }
              {
                name = "Last";
                key = "l";
                command = "last-window";
              }
              {
                name = "Rename";
                key = "r";
                command = ''command-prompt -I "#W" "rename-window -- \"%%\""'';
              }
              { separator = true; }
              {
                name = "Create";
                key = "c";
                command = ''new-window -c "#{pane_current_path}"'';
              }
              (assert (with config.programs.tmux; tmux-which-key.enable -> !disableConfirmationPrompt); {
                name = "Kill";
                key = "k";
                command = ''confirm-before -p "Kill window #W? (y/N)" kill-window'';
              })
              { separator = true; }
              {
                name = "Split Vertically";
                key = "v";
                command = ''split-window -v -c "#{pane_current_path}"'';
              }
              {
                name = "Split Horizontally";
                key = "h";
                command = ''split-window -h -c "#{pane_current_path}"'';
              }
              { separator = true; }
              {
                name = "Rotate";
                key = "i";
                command = "rotate-window";
                transient = true;
              }
              {
                name = "Rotate Reverse";
                key = "M-i";
                command = "rotate-window -D";
                transient = true;
              }
              { separator = true; }
              {
                name = "⇨ Swap Windows";
                key = "s";
                menu = [
                  close
                  { separator = true; }
                  {
                    name = "Left  ←";
                    key = "n";
                    command = ''swap-window -d -t "{previous}"'';
                    transient = true;
                  }
                  {
                    name = "Right →";
                    key = "o";
                    command = ''swap-window -d -t "{next}"'';
                    transient = true;
                  }
                ];
              }
              {
                name = "⇨ Layout";
                key = "L";
                menu = [
                  close
                  { separator = true; }
                  {
                    name = "Last";
                    key = "l";
                    command = "select-layout -o";
                    transient = true;
                  }
                  { separator = true; }
                  {
                    name = "Next";
                    key = "n";
                    command = "next-layout";
                    transient = true;
                  }
                  {
                    name = "Previous";
                    key = "p";
                    command = "previous-layout";
                    transient = true;
                  }
                  { separator = true; }
                  {
                    name = "Tiled";
                    key = "t";
                    command = "select-layout tiled";
                    transient = true;
                  }
                  {
                    name = "Horizontal";
                    key = "h";
                    command = "select-layout even-horizontal";
                    transient = true;
                  }
                  {
                    name = "Vertical";
                    key = "v";
                    command = "select-layout even-vertical";
                    transient = true;
                  }
                  {
                    name = "Horizontal Main";
                    key = "H";
                    command = "select-layout main-horizontal";
                    transient = true;
                  }
                  {
                    name = "Vertical Main";
                    key = "V";
                    command = "select-layout main-vertical";
                    transient = true;
                  }
                ];
              }
            ];
          }
          {
            key = "s";
            name = "⇨ Sessions";
            menu = [
              close
              { separator = true; }
              {
                name = "Choose";
                key = "s";
                command = "choose-tree -Zs";
              }
              {
                name = "Create";
                key = "c";
                command = "new-session";
              }
              {
                name = "Rename";
                key = "r";
                command = ''command-prompt -I "#S" "rename-session -- \"%%\""'';
              }
            ];
          }
          {
            name = "⇨ Client";
            key = "c";
            menu = [
              close
              { separator = true; }
              {
                name = "Choose";
                key = "c";
                command = "choose-client -Z";
              }
              {
                name = "Last";
                key = "l";
                command = "switch-client -l";
              }
              {
                name = "Next";
                key = "n";
                command = "switch-client -n";
              }
              {
                name = "Previous";
                key = "p";
                command = "switch-client -p";
              }
              { separator = true; }
              {
                name = "Detach";
                key = "D";
                command = "detach-client";
              }
              {
                name = "Suspend";
                key = "Z";
                command = "suspend-client";
              }
              {
                name = "Refresh";
                key = "R";
                command = "refresh-client";
              }
              { separator = true; }
              {
                name = "Customize";
                key = ",";
                command = "customize-mode -Z";
              }
            ];
          }
        ];
      };
    };

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-save C-s
          set -g @resurrect-restore M-s
          set -g @resurrect-processes 'micro ~ranger ~"nixos-container root-login" ~"nixos-container run"'
          set -g @resurrect-save-shell-history on
          set -g @resurrect-capture-pane-contents on
        '';
      }
      { plugin = yank; }
      { plugin = jump; }
      {
        plugin = gruvbox;
        extraConfig = ''
          # currently has no effect due to old plugin version
          # TODO update plugin in nixpkgs to get this option
          set -g @tmux-gruvbox-statusbar-alpha true
        '';
        # FIXME stylix overrides the statusbar color applied by this plugin
        # because it adds to `tmux.extraConfig` which comes after the plugins.
        # This is a problem for multiple programs, like e.g. kakoune.
        # There should be a convention in NixOS and home-manager
        # to have `extraConfig` be `lib.types.lines` (which it usually is)
        # so one can use `lib.mkBefore` and `lib.mkAfter` to avoid this,
        # and especially to have generate the final config file by merging
        # into `extraConfig` instead of `xdg.configFile.foo.source = …`.
      }
      { plugin = sessionist; }
      # {
      #   plugin = window-name;
      #   extraConfig = ''
      #     set -g @tmux_window_name_shells "['bash', 'fish', 'sh', 'zsh', 'nu', 'elvish']"
      #     set -g @tmux_window_name_icon_style "'name_and_icon'"
      #   '';
      # }
      {
        plugin = fuzzback;
        extraConfig = ''
          set -g @fuzzback-bind /
          set -g @fuzzback-popup 1
        '';
      }
    ];
  };
}
