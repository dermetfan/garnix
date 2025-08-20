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

            rec {
              mode = "goto";
              docstring = "buffer top";
              key = "g";
              effect = key;
            }
            {
              mode = "goto";
              docstring = "line end";
              key = "o";
              effect = "l";
            }
            {
              mode = "goto";
              docstring = "line begin";
              key = "n";
              effect = "h";
            }
            {
              mode = "goto";
              docstring = "line non-blank start";
              key = "h";
              effect = "i";
            }
            {
              mode = "goto";
              docstring = "buffer bottom";
              key = "i";
              effect = "j";
            }
            rec {
              mode = "goto";
              docstring = "buffer end";
              key = "e";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "window top";
              key = "t";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "window bottom";
              key = "b";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "window center";
              key = "c";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "last buffer";
              key = "a";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "file";
              key = "f";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "last buffer change";
              key = ".";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "definition";
              key = "d";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "references";
              key = "r";
              effect = key;
            }
            rec {
              mode = "goto";
              docstring = "type definition";
              key = "y";
              effect = key;
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
              docstring = "select next hump";
              mode = "normal";
              key = "<c-w>";
              effect = ": select-next-hump<ret>";
            }
            {
              docstring = "select previous hump";
              mode = "normal";
              key = "<c-b>";
              effect = ": select-previous-hump<ret>";
            }
            {
              # By default, this scrolls a page down.
              # <c-b> usually scrolls a page up but is remapped above.
              # Let's disable this for unity.
              mode = "normal";
              key = "<c-f>";
              effect = ": <esc>";
            }
            {
              docstring = "extend next hump";
              mode = "normal";
              key = "<c-W>";
              effect = ": extend-next-hump<ret>";
            }
            {
              docstring = "extend previous hump";
              mode = "normal";
              key = "<c-B>";
              effect = ": extend-previous-hump<ret>";
            }

            {
              docstring = "move lines down";
              mode = "normal";
              key = ''"'"'';
              effect = ": move-lines-down %val{count}<ret>";
            }
            {
              docstring = "move lines up";
              mode = "normal";
              key = ''"<a-'>"'';
              effect = ": move-lines-up %val{count}<ret>";
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
              docstring = "search";
              mode = "user";
              key = "/";
              effect = "/";
            }
            {
              docstring = "search backward";
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
              docstring = "extend search backward";
              mode = "user";
              key = "<a-?>";
              effect = "<a-?>";
            }

            {
              docstring = "fzf mode";
              mode = "user";
              key = "f";
              effect = ": enter-user-mode fzf<ret>";
            }
            {
              mode = "fzf";
              docstring = "file";
              key = "f";
              effect = ": peneira-files<ret>";
            }
            {
              mode = "fzf";
              docstring = "file (local)";
              key = "F";
              effect = ": peneira-local-files<ret>";
            }
            {
              mode = "fzf";
              docstring = "file (recent)";
              key = "<a-f>";
              effect = ": peneira-mru<ret>";
            }
            {
              mode = "fzf";
              docstring = "file (recent global)";
              key = "<a-F>";
              effect = ": peneira-mru -global -cwd-relative<ret>";
            }
            {
              mode = "fzf";
              docstring = "line";
              key = "l";
              effect = ": peneira-lines<ret>";
            }

            {
              docstring = "focus toggle";
              mode = "user";
              key = "F";
              effect = ": focus-toggle<ret>";
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
              key = "<a-c>";
              effect = ": comment-block<ret>";
            }

            {
              docstring = "case convert mode";
              mode = "user";
              key = "C";
              effect = ": enter-user-mode case<ret>";
            }

            {
              docstring = "easymotion mode";
              mode = "user";
              key = "m";
              effect = ": enter-user-mode easymotion-custom<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "→ 🔍";
              key = if cfg.remapMovement then "o" else "l";
              effect = ": easymotion-streak-forward<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "← 🔍";
              key = if cfg.remapMovement then "n" else "h";
              effect = ": easymotion-streak-backward<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "→";
              key = "w";
              effect = ": easymotion-w<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "←";
              key = "b";
              effect = ": easymotion-b<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "↓";
              key = if cfg.remapMovement then "i" else "j";
              effect = ": easymotion-j<ret>";
            }
            {
              mode = "easymotion-custom";
              docstring = "↑";
              key = if cfg.remapMovement then "r" else "k";
              effect = ": easymotion-k<ret>";
            }

            {
              docstring = "mark mode";
              mode = "user";
              key = "M";
              effect = ": enter-user-mode mark<ret>";
            }
            {
              docstring = "mark word";
              mode = "mark";
              key = "w";
              effect = ": mark-word<ret>";
            }
            {
              docstring = "mark pattern";
              mode = "mark";
              key = "/";
              effect = ": mark-set ";
            }
            {
              docstring = "unmark";
              mode = "mark";
              key = "d";
              effect = ": mark-del ";
            }
            {
              docstring = "unmark all";
              mode = "mark";
              key = "D";
              effect = ": mark-clear<ret>";
            }

            {
              docstring = "registers info";
              mode = "user";
              key = "r";
              effect = ": info-registers<ret>";
            }
            {
              docstring = "registers buffer";
              mode = "user";
              key = "R";
              effect = ": list-registers<ret>";
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
              docstring = "phantom selection mode";
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
              key = "<a-s>";
              effect = ": phantom-selection-select-all; phantom-selection-clear<ret>";
            }
            {
              docstring = "select next phantom selection";
              mode = "phantom";
              key = if cfg.remapMovement then "j" else "n";
              effect = ": phantom-selection-iterate-next<ret>";
            }
            {
              docstring = "select previous phantom selection";
              mode = "phantom";
              key = "<a-" + (if cfg.remapMovement then "j" else "n") + ">";
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
              key = "<a-s>";
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
              name = "BufCreate";
              option = ".*";
              commands = ''
                smarttab
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
              option = "filetype=(nix|beancount)";
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
              option = "filetype=beancount";
              commands = ''
                set-option window comment_line \;
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

                set-option buffer formatcmd 'zig fmt'
                set-option global lsp_server_configuration zls.zig_lib_path="%sh{zig env | jq -r .lib_dir}/lib/zig"
                set-option -add global lsp_server_configuration zls.warn_style=true
                set-option -add global lsp_server_configuration zls.enable_semantic_tokens=true
              '';
            }
            {
              name = "WinSetOption";
              option = "filetype=(nix|zig|rust|go|haskell|beancount)";
              commands = ''
                set-option window lsp_hover_anchor true
                set-option window lsp_auto_highlight_references true
                set-face window Reference default,rgba:38383838+d
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
              '';
            }
          ];
        };
        extraConfig = let
          numberLinesFlags = with config.programs.kakoune.config.numberLines;
            (lib.optional relative "-relative")
            ++ (lib.optional highlightCursor "-hlcursor")
            ++ (lib.optional (separator != null) "-separator ${separator}");
        in ''
          enable-auto-pairs
          powerline-start

          require-module easymotion
          require-module mru-files
          require-module peneira

          set-option -add global mru_files_ignore_sh %{
            case "$1" in
              /tmp/tmp.*.fish)
              */.git/*)
              */.hg/*)
                return 0 ;;
            esac
            false
          }

          # https://github.com/gustavo-hms/peneira/blob/bd5b8d0c1cd3e98b6d5350f5ea2131576dcfdea4/README.md#peneira-mru
          set-option global mru_files_max 100

          # https://github.com/gustavo-hms/peneira/blob/bd5b8d0c1cd3e98b6d5350f5ea2131576dcfdea4/README.md#caveats
          remove-highlighter global/number-lines${lib.optionalString (numberLinesFlags != []) "_"}${builtins.concatStringsSep "_" numberLinesFlags}
          hook global WinCreate .+ %{
            add-highlighter window/number-lines number-lines ${toString numberLinesFlags}
          }

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
          kakoune-vertical-selection
          kak-auto-pairs
          kakoune-lsp
          kak-ansi
          kakboard
          powerline-kak
          active-window-kak

          # above:     in nixpkgs
          # below: not in nixpkgs

          easymotion
          sudo-write
          move-lines
          smarttab
          surround
          wordcount
          tug
          fetch
          case
          smart-quotes
          close-tag
          phantom-selection
          shellcheck
          change-directory
          explain-shell
          elvish
          beancount
          crosshairs
          table
          local-kakrc
          peneira
          luar # dependency of peneira
          mru-files # optional dependency of peneira
          expand
          tmux-info # dependency of tmux-kak-copy-mode
          csv
          registers
          mark
          hump
          interactively
          palette
          focus
        ];
      };

      bat.enable = true; # peneira
      skim.enable = true; # peneira
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
            args = [
              "--config-path"
              (pkgs.writers.writeJSON "zls.json" {
                # https://kristoff.it/blog/improving-your-zls-experience/
                enable_build_on_save = true;
                build_on_save_step = "check";

                enable_autofix = true;
              })
            ];
          };

          haskell = {
            filetypes = [ "haskell" "lhaskell" "cabalproject" ];
            roots = [ "Setup.hs" "stack.yaml" "*.cabal" "cabal.project" ];
            command = lib.getExe (pkgs.writeShellApplication {
              # https://nixos.org/manual/nixpkgs/stable/#haskell-language-server
              name = "haskell-language-server-wrapper-wrapper";
              text = ''
                if command -v haskell-language-server-wrapper >/dev/null 2>&1; then
                  exec haskell-language-server-wrapper "$@"
                else
                  exec haskell-language-server "$@"
                fi
              '';
            });
            args = [ "--lsp" ];
          };

          beancount = {
            filetypes = [ "beancount" ];
            roots = [ "*.beancount" ];
            command = "beancount-language-server";
            args = [ "--stdio" ];
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

      fd # peneira

      lua5_3 # easymotion

      # kak-lsp
      self.inputs.nil.packages.${pkgs.system}.default
      gopls go
      rust-analyzer
      zls jq
      yaml-language-server
      flow
      phpPackages.psalm
      beancount-language-server
    ];
  };
}
