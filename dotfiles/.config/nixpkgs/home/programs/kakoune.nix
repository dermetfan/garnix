{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.kakoune;
in {
  options.config.programs.kakoune = with lib; {
    enable = mkOption {
      type = types.bool;
      default = config.programs.kakoune.enable;
      defaultText = "<option>config.programs.kakoune.enable</option>";
      description = "Whether to configure kakoune.";
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

  config = lib.mkIf cfg.enable {
    programs.kakoune = {
      config = {
        colorScheme = "gruvbox";
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
            mode = "normal";
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
            name = "ModuleLoaded";
            option = "nix";
            commands = ''
              set-option buffer indentwidth 2
              set-option buffer tabstop 2

              # smarttab plugin
              expandtab
              set-option buffer softtabstop 2
            '';
          }
          {
            name = "ModuleLoaded";
            option = "zig";
            commands = ''
              set-option buffer indentwidth 4

              # smarttab plugin
              expandtab
              set-option buffer softtabstop 4
            '';
          }
          {
            name = "ModuleLoaded";
            option = "powerline";
            commands = ''
              powerline-theme ${config.programs.kakoune.config.colorScheme}
            '';
          }
          {
            name = "ModuleLoaded";
            option = "fzf";
            commands = ''
              set-option global fzf_file_command 'rg'
              set-option global fzf_highlight_command 'bat'
            '';
          }
          {
            name = "KakEnd";
            option = ".*";
            commands = ''
              state-save-reg-save colon
              state-save-reg-save pipe
              state-save-reg-save slash
            '';
          }
          {
            name = "KakBegin";
            option = ".*";
            commands = ''
              state-save-reg-load colon
              state-save-reg-load pipe
              state-save-reg-load slash
            '';
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
            option = "filetype=zig";
            commands = ''
              lsp-enable-window
            '';
          }
          {
            name = "WinSetOption";
            option = "filetype=zig";
            commands = ''
              set-option buffer formatcmd 'zig fmt'
              set-option window lsp_auto_highlight_references true
              set-option global lsp_server_configuration zls.zig_lib_path="%sh{zig env | jq -r .lib_dir}/lib/zig"
              set-option -add global lsp_server_configuration zls.warn_style=true
              set-option -add global lsp_server_configuration zls.enable_semantic_tokens=true
              hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
              hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
              hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
              hook -once -always window WinSetOption filetype=.* %{
                  remove-hooks window semantic-tokens
              }
            '';
          }
        ];
      };
      extraConfig = ''
        set-option global auto_pairs_enabled true
        set-option global auto_pairs_surround_enabled true
        require-module move-line
        powerline-start
        require-module word-select; word-select-add-mappings

        set-option global state_save_exclude_globs \
            '*/COMMIT_EDITMSG' \
            '*/.git/rebase-merge/git-rebase-todo' \
            '*.commit.hg.txt' \
            '*.histedit.hg.txt'

        set-face global crosshairs_line default,rgb:383838+d
        set-face global crosshairs_column default,rgb:383838+d

        set-option global kakboard_paste_keys p P K <a-p> <a-P> <a-R>

        eval %sh{kak-lsp --kakoune -s $kak_session}
      '';

      plugins = with pkgs.kakounePlugins; [
        kakoune-buffers
        powerline-kak
        fzf-kak
        kak-ansi
        kakoune-state-save
        kakoune-easymotion
        active-window-kak
        kakoune-rainbow
        kakboard
        kak-lsp
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "sudo-write";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "occivink";
            repo = "kakoune-sudo-write";
            rev = "abe6bd6d6e111957d7e84e790e682955b8b319c6";
            sha256 = "05b6hxsqvh3kmi7f139rihx0i9fn2j5fjz7yzy1g4flm8lb0h129";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "move-line";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "alexherbo2";
            repo = "move-line.kak";
            rev = "bc1d08b8668a77297ecc69b05bf6b23ea09b314e";
            sha256 = "0fj502vq99l3xfrsnsd7fszsl538iff7k36jlpqq2jv6yh6mvrnq";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "smarttab";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "andreyorst";
            repo = "smarttab.kak";
            rev = "1dd3f33c4f65da5c13aee5d44b2e77399595830f";
            sha256 = "0g49k47ggppng95nwanv2rqmcfsjsgy3z1764wrl5b49h9wifhg2";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "surround";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "h-youhei";
            repo = "kakoune-surround";
            rev = "efe74c6f434d1e30eff70d4b0d737f55bf6c5022";
            sha256 = "09fd7qhlsazf4bcl3z7xh9z0fklw69c5j32hminphihq74qrry6h";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "wordcount";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "ftonneau";
            repo = "wordcount.kak";
            rev = "1a5216d5acfb7220378e825646b0597ea6219f79";
            sha256 = "1d0k408sd48yy37vgip30rgywl20aj2w56lqimr2nw7cb3ggjk4p";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "tug";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "matthias-margush";
            repo = "tug";
            rev = "23adaadb795af2d86dcb3daf7af3ebe12e932441";
            sha256 = "0qldzh3gr3m7sa1hibbmf1br5lgiqwn84ggm75iin113zc67avbi";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "fetch";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "mmlb";
            repo = "kak-fetch";
            rev = "3e404480caa13bfc9ef7064be45e4d1ec43232a1";
            sha256 = "1dqpllrrx2i4g1rwvx1434zmfx2fn0cv5wq750myf1p9p61rc0bm";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "casing";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "Parasrah";
            repo = "casing.kak";
            rev = "bd579f04bbd17c3d8612ad0505a6641a78e239df";
            sha256 = "13k1cx94ix7z9ny092fyplr6r2bqf5d5r1vr1iqvr9zp3c6v9hda";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "smart-quotes";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "chambln";
            repo = "kakoune-smart-quotes";
            rev = "7eeebc475b3d5c2b8d471c42ed8b3c8f75a81cf9";
            sha256 = "14fs48n29nd86ngwv6by3xb5yyd46q15xg6mvishi34g99nicm38";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "close-tag";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "h-youhei";
            repo = "kakoune-close-tag";
            rev = "c719939cef45efbba24d3a6dbcc1aa273bbb8b1a";
            sha256 = "0mfzgkgm0dbyxb7f2ghixlv4ad5kml433c2gpzjk3k1x4vxwz9dw";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "phantom-selection";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "occivink";
            repo = "kakoune-phantom-selection";
            rev = "034d7a79f7f07e659e632468ef64c48ae82730f2";
            sha256 = "0bwa6r7nqysjchsfjpj6jbxwvqb3dflh1ygij3pnyn29jplc8068";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "shellcheck";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "whereswaldon";
            repo = "shellcheck.kak";
            rev = "4e633978c119bbb71f215828f7b59cea71a2c5a4";
            sha256 = "1629jh4387ybl2iizyqc7k7r1n1rx2ljg5acn294z2jqfxg2n6mj";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "change-directory";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "alexherbo2";
            repo = "change-directory.kak";
            rev = "a1e75c10abb65276d2481e5d7a349ab7911d3fd3";
            sha256 = "1h57xi5r3a7lf4jh6cl46svampb73j9cn2rncad7ag55jq0d6zpc";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "explain-shell";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "ath3";
            repo = "explain-shell.kak";
            rev = "503549ea7022a9ce9207be362d2fb74f7f6a72d6";
            sha256 = "103kvf8jry2lwx74z1hwnmw87vhh3x95ppn2xlmq50w9z8zzh161";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "elvish";
          version = src.rev;
          src = pkgs.fetchFromGitLab {
            owner = "SolitudeSF";
            repo = "elvish.kak";
            rev = "c71caa7575da93365e12fe031f5debc2baf73a6d";
            sha256 = "0czxcnq16hfxvxdv61qbgk8ghxj7dgfh82xyrcasqqi3wswi143p";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "crosshairs";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "insipx";
            repo = "kak-crosshairs";
            rev = "7edba13c535ce1bc67356b1c9461f5d261949d29";
            sha256 = "18f3scwl87a91167zmrxgkmzy3fmmpz0l72cn1dd5fg5c4cgvsal";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "table";
          version = src.rev;
          src = pkgs.fetchFromGitLab {
            owner = "listentolist";
            repo = "kakoune-table";
            rev = "c42ecaa91472cf778d87b289629d82d335e2b1e6";
            sha256 = "1yri5n745bsz9a8lzg4m0kmba7l7p1shsyvnc4cc7q48va0ck35w";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "local-kakrc";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "dgmulf";
            repo = "local-kakrc";
            rev = "2f3107e4aa1b1416f43e7551c18f8f6f0ef90348";
            sha256 = "1dgjk1spzbjjw3sqsidqavwmbcb3kmb2ahfq5fps43c9v13k8m1l";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "expand";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "occivink";
            repo = "kakoune-expand";
            rev = "e2c3c31e18a19ef73b8cc31e8b84255e11265689";
            sha256 = "03afg4czqhsh21ig1mczi6jp4vypzjrbif61v2n87371v5zw6xbs";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "neuron";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "MilanVasko";
            repo = "neuron-kak";
            rev = "bcf824ac837de95045e54d6d5a9fba48c06013e8";
            sha256 = "1fzadn5bmd0nazm0lh2nh5r1ayggafi5qrg95c06z5z7ppkmdplb";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "buffer-switcher";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "occivink";
            repo = "kakoune-buffer-switcher";
            rev = "6a27c45db87a23070c34fab36d2f8d812cd002a6";
            sha256 = "1rmwy317908v8p54806m721bpzm8sgygb9abri34537ka6r05y5j";
          };
        })
        # dependency of tmux-kak-copy-mode
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "tmux-kak-info";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "jbomanson";
            repo = "tmux-kak-info.kak";
            rev = "180bdabea21d7764663aa14c4f30f406f3aa2732";
            sha256 = "0wk7h9g801k4gdc79cb5fjd7l4s3y5lyw7y1n3aaw8dzhnyfyf0r";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "csv";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "gspia";
            repo = "csv.kak";
            rev = "00d0c4269645e15c8f61202e265328c470cd85c2";
            sha256 = "03hcnxchgbd2h5w2wn3c16x1fb2264wjjrfbkwrdj0vfrgswk3nx";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "registers";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "Delapouite";
            repo = "kakoune-registers";
            rev = "9531947baecd83c1d4c3bea0adf10f4462f1e120";
            sha256 = "08v9ndghh7wvr8rsrqm05gksk9ai5vnwvw9gwqasbppb48cv4a8c";
          };
        })
        (pkgs.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = "word-select";
          version = src.rev;
          src = pkgs.fetchFromGitHub {
            owner = "alexherbo2";
            repo = "word-select.kak";
            rev = "48d9d4c59b5ab9669314c2cd40d37601d36b62da";
            sha256 = "0w0shhmhaz9cidbkbh76vxmq580z8q3bi2rfkpjlnjmvid7h9vlc";
          };
        })
      ];
    };

    xdg.configFile."kak-lsp/kak-lsp.toml".source = (pkgs.formats.toml {}).generate "kak-lsp.toml" {
      snippet_support = true;
      verbosity = 2;

      semantic_tokens = {
        type = "type";
        variable = "variable";
        namespace = "module";
        function = "function";
        string = "string";
        keyword = "keyword";
        operator = "operator";
        comment = "comment";
      };

      semantic_token_modifiers = {
        documentation = "documentation";
        readonly = "default+d";
      };

      server.timeout = 1800;

      language = {
        nix = {
          filetypes = ["nix"];
          roots = ["flake.nix" "shell.nix" "release.nix" ".git" ".hg" "default.nix"];
          command = "rnix-lsp";
        };

        php = {
          filetypes = ["php"];
          roots = ["psalm.xml" "composer.json" ".git" ".hg"];
          command = "psalm";
          args = ["--language-server"];
        };

        yaml = {
          filetypes = ["yaml" "yml"];
          roots = [".git" ".hg"];
          command = "yaml-language-server";
          args = ["--stdio"];
        };

        zig = {
          filetypes = ["zig"];
          roots = ["build.zig"];
          command = "zls";
        };
      };
    };

    home.packages = with pkgs; [
      editorconfig-core-c
      editorconfig-checker

      powerline-fonts
      shellcheck
      perl socat # gdb

      # kak-lsp
      rnix-lsp
      zls jq
      yaml-language-server
      phpPackages.psalm
    ];

    programs = {
      bat.enable = true;
      ripgrep.enable = true; # fzf
    };
  };
}
