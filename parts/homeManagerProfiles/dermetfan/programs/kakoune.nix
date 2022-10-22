{ self, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.kakoune;
in {
  options.profiles.dermetfan.programs.kakoune = with lib; {
    enable = mkEnableOption "kakoune" // {
      default = config.programs.kakoune.enable;
    };

    remapMovement = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable a keymap
        that uses JKIL instead of HJKL,
        but for the Norman keyboard layout,
        so it is NIRO.
      '';
    };
  };

  config = {
    programs = {
      kakoune = {
        config = {
          colorScheme = "cosy-gruvbox";
          indentWidth = 0;
          numberLines = {
            enable = true;
            highlightCursor = true;
          };
          showMatching = true;
          showWhitespace = {
            enable = true;
            nonBreakingSpace = "⍽";
            tab = "→";
            space = "\\ ";
            lineFeed = "\\ ";
          };
          tabStop = 4;
          wrapLines = {
            enable = true;
            indent = true;
            word = true;
          };
          ui = {
            assistant = "none";
            statusLine = "top";
            enableMouse = true;
            setTitle = true;
          };
          keyMappings = (lib.optionals cfg.remapMovement [
            {
              mode = "normal";
              key = "r";
              effect = "k";
            }
            {
              mode = "normal";
              key = "k";
              effect = "r";
            }
            {
              mode = "normal";
              key = "R";
              effect = "K";
            }
            {
              mode = "normal";
              key = "K";
              effect = "R";
            }

            {
              mode = "normal";
              key = "i";
              effect = "j";
            }
            {
              mode = "normal";
              key = "h";
              effect = "i";
            }
            {
              mode = "normal";
              key = "I";
              effect = "J";
            }
            {
              mode = "normal";
              key = "H";
              effect = "I";
            }

            {
              mode = "normal";
              key = "n";
              effect = "h";
            }
            {
              mode = "normal";
              key = "j";
              effect = "n";
            }
            {
              mode = "normal";
              key = "N";
              effect = "H";
            }
            {
              mode = "normal";
              key = "J";
              effect = "N";
            }
            {
              mode = "normal";
              key = "<a-n>";
              effect = "<a-h>";
            }
            {
              mode = "normal";
              key = "<a-j>";
              effect = "<a-n>";
            }
            /*
            { # <a-H> effect does not exist
              mode = "normal";
              key = "<a-N>";
              effect = "<a-H>";
            }
            */
            {
              mode = "normal";
              key = "<a-J>";
              effect = "<a-N>";
            }
            {
              mode = "normal";
              key = "<a-h>";
              effect = "<a-j>";
            }
            {
              mode = "normal";
              key = "<a-H>";
              effect = "<a-J>";
            }

            {
              mode = "normal";
              key = "o";
              effect = "l";
            }
            {
              mode = "normal";
              key = "l";
              effect = "o";
            }
            {
              mode = "normal";
              key = "O";
              effect = "L";
            }
            {
              mode = "normal";
              key = "L";
              effect = "O";
            }
            {
              mode = "normal";
              key = "<a-o>";
              effect = "<a-l>";
            }
            {
              mode = "normal";
              key = "<a-l>";
              effect = "<a-o>";
            }
            /*
            { # <a-L> does not exist
              mode = "normal";
              key = "<a-O>";
              effect = "<a-L>";
            }
            */
            {
              mode = "normal";
              key = "<a-L>";
              effect = "<a-O>";
            }

            {
              mode = "easymotion-custom";
              docstring = "char →";
              key = "l";
              effect = ": easy-motion-f<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "char ←";
              key = "u";
              effect = ": easy-motion-alt-f<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "word →";
              key = "o";
              effect = ": easy-motion-w<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "word ←";
              key = "n";
              effect = ": easy-motion-b<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "WORD →";
              key = "O";
              effect = ": easy-motion-W<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "WORD ←";
              key = "N";
              effect = ": easy-motion-B<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "line ↓";
              key = "i";
              effect = ": easy-motion-j<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "line ↑";
              key = "r";
              effect = ": easy-motion-k<ret>";
            }

            {
              docstring = "view mode";
              mode = "normal";
              key = "v";
              effect = ": enter-user-mode view-custom<ret>";
            }
            {
              docstring = "view lock mode";
              mode = "normal";
              key = "V";
              effect = ": enter-user-mode -lock view-custom<ret>";
            }
            {
              mode = "view-custom";
              docstring = "center cursor (vertically)";
              key = "v";
              effect = "vv";
            }
            {
              mode = "view-custom";
              docstring = "center cursor (vertically)";
              key = "c";
              effect = "vc";
            }
            {
              mode = "view-custom";
              docstring = "center cursor (horizontally)";
              key = "m";
              effect = "vm";
            }
            {
              mode = "view-custom";
              docstring = "cursor on top";
              key = "t";
              effect = "vt";
            }
            {
              mode = "view-custom";
              docstring = "cursor on bottom";
              key = "b";
              effect = "vb";
            }
            {
              mode = "view-custom";
              docstring = "scroll up";
              key = "r";
              effect = "5vkgc";
            }
            {
              mode = "view-custom";
              docstring = "scroll down";
              key = "i";
              effect = "5vjgc";
            }
            {
              mode = "view-custom";
              docstring = "scroll left";
              key = "n";
              effect = "5vh";
            }
            {
              mode = "view-custom";
              docstring = "scroll right";
              key = "o";
              effect = "5vl";
            }
            {
              mode = "view-custom";
              docstring = "scroll one page up";
              key = "<pageup>";
              effect = "<c-b>";
            }
            {
              mode = "view-custom";
              docstring = "scroll one page down";
              key = "<pagedown>";
              effect = "<c-f>";
            }
            {
              mode = "view-custom";
              docstring = "scroll half a page up";
              key = "<s-pageup>";
              effect = "<c-u>";
            }
            {
              mode = "view-custom";
              docstring = "scroll half a page down";
              key = "<s-pagedown>";
              effect = "<c-d>";
            }
          ]) ++ [
            {
              docstring = "case insensitive search";
              mode = "normal";
              key = "/";
              effect = "/(?i)";
            }
            {
              docstring = "case insensitive backward search";
              mode = "normal";
              key = "<a-/>";
              effect = "<a-/>(?i)";
            }
            {
              docstring = "case insensitive extend search";
              mode = "normal";
              key = "?";
              effect = "?(?i)";
            }
            {
              docstring = "case insensitive backward extend search";
              mode = "normal";
              key = "<a-?>";
              effect = "<a-?>(?i)";
            }

            {
              docstring = "search";
              mode = "user";
              key = "/";
              effect = "/";
            }
            {
              docstring = "backward search";
              mode = "user";
              key = "<a-/>";
              effect = "<a-/>";
            }
            {
              docstring = "extend search";
              mode = "user";
              key = "?";
              effect = "?";
            }
            {
              docstring = "backward extend search";
              mode = "user";
              key = "<a-?>";
              effect = "<a-?>";
            }

            {
              docstring = "fzf mode";
              mode = "user";
              key = "f";
              effect = ": fzf-mode<ret>";
            }

            {
              docstring = "(un)comment line";
              mode = "user";
              key = "c";
              effect = ": comment-line<ret>";
            }
            {
              docstring = "(un)comment block";
              mode = "user";
              key = "<s-c>";
              effect = ": comment-block<ret>";
            }

            {
              docstring = "easymotion mode";
              mode = "user";
              key = "m";
              effect = ": enter-user-mode easymotion${lib.optionalString cfg.remapMovement "-custom"}<ret>";
            }

            {
              docstring = "move line down";
              mode = "normal";
              key = "\"'\"";
              effect = ": move-line-below<ret>";
            }
            {
              docstring = "move line up";
              mode = "normal";
              key = "\"<a-'>\"";
              effect = ": move-line-above<ret>";
            }

            {
              docstring = "scroll half a page up";
              mode = "normal";
              key = "<s-pageup>";
              effect = "<c-u>";
            }
            {
              docstring = "scroll half a page down";
              mode = "normal";
              key = "<s-pagedown>";
              effect = "<c-d>";
            }

            {
              docstring = "expand selection";
              mode = "normal";
              key = "+";
              effect = ": expand<ret>";
            }

            {
              docstring = "surround mode";
              mode = "user";
              key = "w";
              effect = ": enter-user-mode surround<ret>";
            }
            {
              docstring = "surround";
              mode = "surround";
              key = "n";
              effect = ": surround<ret>";
            }
            {
              docstring = "change surround";
              mode = "surround";
              key = "m";
              effect = ": change-surround<ret>";
            }
            {
              docstring = "delete surround";
              mode = "surround";
              key = "d";
              effect = ": delete-surround<ret>";
            }
            {
              docstring = "select surround";
              mode = "surround";
              key = "s";
              effect = ": select-surround<ret>";
            }

            {
              docstring = "enter phantom selection mode";
              mode = "user";
              key = "p";
              effect = ": enter-user-mode phantom<ret>";
            }
            {
              docstring = "add selections to phantom selections";
              mode = "phantom";
              key = "s";
              effect = ": phantom-selection-add-selection<ret>";
            }
            {
              docstring = "clear phantom selections";
              mode = "phantom";
              key = "S";
              effect = ": phantom-selection-select-all; phantom-selection-clear<ret>";
            }
            {
              docstring = "select next phantom selection";
              mode = "phantom";
              key = "n";
              effect = ": phantom-selection-iterate-next<ret>";
            }
            {
              docstring = "select previous phantom selection";
              mode = "phantom";
              key = "N";
              effect = ": phantom-selection-iterate-prev<ret>";
            }

            {
              docstring = "enable system clipboard";
              mode = "user";
              key = "s";
              effect = ": kakboard-enable<ret>";
            }
            {
              docstring = "disable system clipboard";
              mode = "user";
              key = "S";
              effect = ": kakboard-disable<ret>";
            }

            {
              docstring = "tag mode";
              mode = "user";
              key = "t";
              effect = ": enter-user-mode tag<ret>";
            }
            {
              docstring = "close tag";
              mode = "tag";
              key = "c";
              effect = ": close-tag<ret>";
            }
            {
              docstring = "surround with tag";
              mode = "tag";
              key = "n";
              effect = ": surround-with-tag<ret>";
            }
            {
              docstring = "change tag";
              mode = "tag";
              key = "m";
              effect = ": change-surrounding-tag<ret>";
            }
            {
              docstring = "delete tag";
              mode = "tag";
              key = "d";
              effect = ": delete-surrounding-tag<ret>";
            }
            {
              docstring = "select tag";
              mode = "tag";
              key = "s";
              effect = ": select-surrounding-tag<ret>";
            }

            {
              docstring = "language server mode";
              mode = "user";
              key = "l";
              effect = ": enter-user-mode lsp<ret>";
            }

            {
              docstring = "buffers mode";
              mode = "user";
              key = "b";
              effect = ": enter-user-mode buffers<ret>";
            }
            {
              docstring = "info";
              mode = "buffers";
              key = "i";
              effect = ": info-buffers<ret>";
            }
            {
              docstring = "buffer switcher";
              mode = "buffers";
              key = "b";
              effect = ": buffer-switcher<ret>";
            }

            {
              docstring = "neuron mode";
              mode = "user";
              key = "n";
              effect = ": enter-user-mode neuron<ret>";
            }

            {
              mode = "neuron";
              docstring = "create new zettel with random ID";
              key = "n";
              effect = ": neuron-new<ret>";
            }
            {
              mode = "neuron";
              docstring = "create new zettel";
              key = "N";
              effect = ": neuron-new ";
            }
            {
              mode = "neuron";
              docstring = "search titles and open zettel";
              key = "s";
              effect = ": neuron-search-and-open<ret>";
            }
            {
              mode = "neuron";
              docstring = "search all and open zettel";
              key = "S";
              effect = ": neuron-search-and-open -a<ret>";
            }
            {
              mode = "neuron";
              docstring = "search titles and insert zettel ID";
              key = "i";
              effect = ": neuron-search-and-insert<ret>";
            }
            {
              mode = "neuron";
              docstring = "search all and insert zettel ID";
              key = "I";
              effect = ": neuron-search-and-insert -a<ret>";
            }
          ];
          hooks = [
            {
              name = "WinCreate";
              option = "^[^*]+$";
              commands = ''
                editorconfig-load
              '';
            }
            {
              name = "WinSetOption";
              option = "filetype=nix";
              commands = ''
                set-option window indentwidth 2
                set-option window tabstop 2

                # smarttab plugin
                expandtab
                set-option window softtabstop 2
              '';
            }
            {
              name = "WinSetOption";
              option = "filetype=zig";
              commands = ''
                set-option window indentwidth 4

                # smarttab plugin
                expandtab
                set-option window softtabstop 4
              '';
            }
            {
              name = "ModuleLoaded";
              option = "powerline";
              commands = ''
                powerline-theme base16-gruvbox
                powerline-separator global triangle-inverted
              '';
            }
            {
              name = "ModuleLoaded";
              option = "fzf";
              commands = ''
                set-option global fzf_implementation 'sk'
                set-option global fzf_highlight_command 'bat'
              '';
            }
            {
              name = "ModuleLoaded";
              option = "fzf-file";
              commands = ''
                set-option global fzf_file_command 'fd'
              '';
            }
            {
              name = "KakEnd";
              option = ".*";
              commands = lib.concatMapStrings (register: ''
                state-save-reg-save ${register}
              '') [
                "colon"
                "pipe"
                "slash"
                "dquote"
                "arobase"
                "caret"
              ];
            }
            {
              name = "KakBegin";
              option = ".*";
              commands = lib.concatMapStrings (register: ''
                state-save-reg-load ${register}
              '') [
                "colon"
                "pipe"
                "slash"
                "dquote"
                "arobase"
                "caret"
              ];
            }
            {
              name = "FocusOut";
              option = ".*";
              commands = ''
                state-save-reg-save dquote
              '';
            }
            {
              name = "FocusIn";
              option = ".*";
              commands = ''
                state-save-reg-load dquote
              '';
            }
            {
              name = "WinSetOption";
              option = "filetype=(zig|go)";
              commands = ''
                set-option window lsp_hover_anchor true
                hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
                hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
                hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
                hook -once -always window WinSetOption filetype=.* %{
                    remove-hooks window semantic-tokens
                }
                lsp-enable-window
                lsp-auto-signature-help-enable
                lsp-diagnostic-lines-enable window
                lsp-inline-diagnostics-enable window
                lsp-inlay-diagnostics-enable window ${""/*FIXME doesn't work automatically*/}
              '';
            }
            {
              name = "WinSetOption";
              option = "filetype=zig";
              commands = ''
                set-option buffer formatcmd 'zig fmt'
                set-option global lsp_server_configuration zls.zig_lib_path="%sh{zig env | jq -r .lib_dir}/lib/zig"
                set-option -add global lsp_server_configuration zls.warn_style=true
                set-option -add global lsp_server_configuration zls.enable_semantic_tokens=true
              '';
            }
          ];
        };
        extraConfig = ''
          enable-auto-pairs
          require-module move-line
          powerline-start
          require-module word-select; word-select-add-mappings

          set-option global state_save_exclude_globs \
              'COMMIT_EDITMSG' \
              '*/.git/rebase-merge/git-rebase-todo' \
              '*.commit.hg.txt' \
              '*.histedit.hg.txt'

          set-face global crosshairs_line default,rgb:383838+d
          set-face global crosshairs_column default,rgb:383838+d

          set-option global kakboard_paste_keys p P <a-p> <a-P> <a-R>

          eval %sh{kak-lsp --kakoune -s $kak_session}
        '';

        plugins = with pkgs.kakounePlugins; [
          kakoune-buffers
          kakoune-rainbow
          kakoune-buffer-switcher
          kakoune-extra-filetypes
          kakoune-state-save
          kakoune-easymotion
          kak-lsp
          kak-fzf
          kak-ansi
          kakboard
          powerline-kak
          active-window-kak

          auto-pairs
          sudo-write
          move-line
          smarttab
          surround
          wordcount
          tug
          fetch
          casing
          smart-quotes
          close-tag
          phantom-selection
          shellcheck
          change-directory
          explain-shell
          elvish
          crosshairs
          table
          local-kakrc
          expand
          neuron
          tmux-info # dependency of tmux-kak-copy-mode
          csv
          registers
          marks
          mark
          word-select
          interactively
          palette
          focus
        ];
      };

      bat.enable = true; # fzf.kak
      skim.enable = true; # fzf.kak
    };

    xdg = {
      configFile."kak-lsp/kak-lsp.toml".source = (pkgs.formats.toml {}).generate "kak-lsp.toml" {
        snippet_support = true;
        verbosity = 2;

        semantic_tokens = [
          {
            token = "comment";
            face = "documentation";
            modifiers = [ "documentation" ];
          }
          {
            token = "comment";
            face = "comment";
          }
          {
            token = "function";
            face = "function";
          }
          {
            token = "keyword";
            face = "keyword";
          }
          {
            token = "namespace";
            face = "module";
          }
          {
            token = "operator";
            face = "operator";
          }
          {
            token = "string";
            face = "string";
          }
          {
            token = "type";
            face = "type";
          }
          {
            token = "variable";
            face = "default+d";
            modifiers = [ "readonly" ];
          }
          {
            token = "variable";
            face = "default+d";
            modifiers = [ "constant" ];
          }
          {
            token = "variable";
            face = "variable";
          }
        ];

        server.timeout = 1800;

        language = {
          nix = {
            filetypes = [ "nix" ];
            roots = [ "flake.nix" "shell.nix" "release.nix" ".git" ".hg" "default.nix" ];
            command = "nil";
          };

          php = {
            filetypes = [ "php" ];
            roots = [ "psalm.xml" "composer.json" ".git" ".hg" ];
            command = "psalm";
            args = [ "--language-server" ];
          };

          yaml = {
            filetypes = [ "yaml" "yml" ];
            roots = [ ".git" ".hg" ];
            command = "yaml-language-server";
            args = [ "--stdio" ];
          };

          javascript = {
            filetypes = [ "javascript" ];
            roots = [ ".flowconfig" ];
            command = "flow";
            args = [ "lsp" ];
          };

          go = {
            filetypes = [ "go" ];
            roots = [ "Gopkg.toml" "go.mod" ".git" ".hg" ];
            command = "gopls";
            offset_encoding = "utf-8";
          };

          rust = {
            filetypes = [ "rust" ];
            roots = [ "Cargo.toml" ];
            command = "rust-analyzer";
            settings_section = "rust-analyzer";
            settings.rust-analyzer.hoverActions.enable = false;
          };

          zig = {
            filetypes = [ "zig" ];
            roots = [ "build.zig" ];
            command = "zls";
          };
        };
      };

      desktopEntries.kakoune = {
        name = "Kakoune";
        genericName = "Text Editor";
        exec = "kak %F";
        terminal = true;
        categories = [ "TextEditor" "ConsoleOnly" "Development" ];
        mimeType = [ "text/plain" "application/json" "text/html" ];
      };
    };

    home.packages = with pkgs; [
      editorconfig-core-c
      editorconfig-checker

      powerline-fonts
      shellcheck
      perl socat # gdb

      fd # fzf.kak

      # kak-lsp
      self.inputs.nil.packages.${pkgs.system}.default
      gopls go
      rust-analyzer
      zls jq
      yaml-language-server
      flow
      phpPackages.psalm
    ];
  };
}
