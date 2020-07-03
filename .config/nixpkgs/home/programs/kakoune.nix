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
          assistant = "cat";
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
            docstring = "add selections to phantom selections";
            mode = "user";
            key = "<a-p>";
            effect = ": phantom-selection-add-selection<ret>";
          }
          {
            docstring = "clear phantom selections";
            mode = "user";
            key = "<a-P>";
            effect = ": phantom-selection-select-all; phantom-selection-clear<ret>";
          }
          {
            docstring = "select next phantom selection";
            mode = "user";
            key = "p";
            effect = ": phantom-selection-iterate-next<ret>";
          }
          {
            docstring = "select previous phantom selection";
            mode = "user";
            key = "P";
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
        ];
        hooks = [
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
        ];
      };
      extraConfig = ''
        set-option global auto_pairs_enabled true
        set-option global auto_pairs_surround_enabled true

        set-option global state_save_exclude_globs \
            '*/COMMIT_EDITMSG' \
            '*/.git/rebase-merge/git-rebase-todo' \
            '*.commit.hg.txt' \
            '*.histedit.hg.txt'

        set-face global crosshairs_line default,rgb:383838+d
        set-face global crosshairs_column default,rgb:383838+d

        set-option global kakboard_paste_keys p P K <a-p> <a-P> <a-R>
      '';
    };

    xdg.configFile = with pkgs.kakounePlugins; {
      "kak/autoload" = {
        source = "${pkgs.kakoune-unwrapped}/share/kak/autoload";
        recursive = true;
      };
      "kak/autoload/auto-pairs.kak".source = "${kak-auto-pairs}/share/kak/autoload/plugins/auto-pairs/auto-pairs.kak";
      "kak/autoload/buffers.kak".source = "${kak-buffers}/share/kak/autoload/plugins/buffers.kak";
      "kak/autoload/powerline".source = "${kak-powerline}/share/kak/autoload/plugins/powerline";
      "kak/autoload/fzf".source = "${kak-fzf}/share/kak/autoload/plugins/fzf";
      "kak/autoload/ansi.kak".source = "${kak-ansi}/share/kak/autoload/plugins/ansi.kak";
      "kak/autoload/state-save.kak".source = pkgs.fetchFromGitLab {
        owner = "Screwtapello";
        repo = "kakoune-state-save";
        rev = "ab7c0c765326a4a80af78857469ee8c80814c52a";
        sha256 = "1q53b1pw0mi1q8h5xv1wxqsj9fa9081r7r6ry1y6vp6q8hdq40q0";
      } + "/state-save.kak";
      "kak/autoload/gdb.kak".source = pkgs.fetchFromGitHub {
        owner = "occivink";
        repo = "kakoune-gdb";
        rev = "57e2467e00a907d2bea798b66c56dcb5c1112efd";
        sha256 = "06djnkfjawfakh14gsg3bxj301yxkc8i6v02yzdaha1j4287lpra";
      } + "/gdb.kak";
      "kak/autoload/easymotion.kak".source = pkgs.fetchFromGitHub {
        owner = "danr";
        repo = "kakoune-easymotion";
        rev = "0ca75450023a149efc70e8e383e459b571355c70";
        sha256 = "15czvl0qj2k767pysr6xk2v31mkhvcbmv76xs2a8yrslchms70b5";
      } + "/easymotion.kak";
      "kak/autoload/sudo-write.kak".source = pkgs.fetchFromGitHub {
        owner = "occivink";
        repo = "kakoune-sudo-write";
        rev = "9a11b5c8c229c517848c069e3614f591a43d6ad3";
        sha256 = "0ga8048z7hkfpl1gjrw76d4dk979a6vjpg8jsnrs3swg493qr6ix";
      } + "/sudo-write.kak";
      "kak/autoload/surround.kak".source = pkgs.fetchFromGitHub {
        owner = "h-youhei";
        repo = "kakoune-surround";
        rev = "efe74c6f434d1e30eff70d4b0d737f55bf6c5022";
        sha256 = "09fd7qhlsazf4bcl3z7xh9z0fklw69c5j32hminphihq74qrry6h";
      } + "/surround.kak";
      "kak/autoload/crosshairs.kak".source = pkgs.fetchFromGitHub {
        owner = "insipx";
        repo = "kak-crosshairs";
        rev = "7edba13c535ce1bc67356b1c9461f5d261949d29";
        sha256 = "18f3scwl87a91167zmrxgkmzy3fmmpz0l72cn1dd5fg5c4cgvsal";
      } + "/crosshairs.kak";
      "kak/autoload/move-line.kak".source = pkgs.fetchFromGitHub {
        owner = "alexherbo2";
        repo = "move-line.kak";
        rev = "00221c1ddb2d9ef984facfbdc71b56b789daddaf";
        sha256 = "1z6793y2ig5pc5w48kg1rphpsswpq485bw3l2aj7qzjfcyzjys6y";
      } + "/rc/move-line.kak";
      "kak/autoload/table.kak".source = pkgs.fetchFromGitLab {
        owner = "listentolist";
        repo = "kakoune-table";
        rev = "61602e8bb7df9bac4d758092980e0fcd16fc7ee2";
        sha256 = "0vf3aiarfcsqqqgjr0bk1fc61pyandq5ksi1kr4wg67n1dm8h3bp";
      } + "/table.kak";
      "kak/autoload/elvish.kak".source = pkgs.fetchFromGitLab {
        owner = "notramo";
        repo = "elvish.kak";
        rev = "d7d8e29dedde1234d11a9a899a2f428944b3f43c";
        sha256 = "1dc9gd1wmjgqhjr01aqhyrc4c53f662xp6b65nzwbksa10vcmm4q";
      } + "/elvish.kak";
      "kak/autoload/wordcount.kak".source = pkgs.fetchFromGitHub {
        owner = "ftonneau";
        repo = "wordcount.kak";
        rev = "1a5216d5acfb7220378e825646b0597ea6219f79";
        sha256 = "1d0k408sd48yy37vgip30rgywl20aj2w56lqimr2nw7cb3ggjk4p";
      } + "/wordcount.kak";
      "kak/autoload/local-kakrc.kak".source = pkgs.fetchFromGitHub {
        owner = "dgmulf";
        repo = "local-kakrc";
        rev = "2f3107e4aa1b1416f43e7551c18f8f6f0ef90348";
        sha256 = "1dgjk1spzbjjw3sqsidqavwmbcb3kmb2ahfq5fps43c9v13k8m1l";
      } + "/rc/local-kakrc.kak";
      "kak/autoload/tug.kak".source = pkgs.fetchFromGitHub {
        owner = "matthias-margush";
        repo = "tug";
        rev = "23adaadb795af2d86dcb3daf7af3ebe12e932441";
        sha256 = "0qldzh3gr3m7sa1hibbmf1br5lgiqwn84ggm75iin113zc67avbi";
      } + "/rc/tug.kak";
      "kak/autoload/smart-quotes.kak".source = pkgs.fetchFromGitHub {
        owner = "chambln";
        repo = "kakoune-smart-quotes";
        rev = "8307bd56652c334e416d8920ad988de69c2a07a0";
        sha256 = "1z2xmcprb5l8ib1xyksp079g26n6y8sqp3hvv9nfpxhls31jncj2";
      } + "/smart-quotes.kak";
      "kak/autoload/explain-shell.kak".source = pkgs.fetchFromGitHub {
        owner = "ath3";
        repo = "explain-shell.kak";
        rev = "503549ea7022a9ce9207be362d2fb74f7f6a72d6";
        sha256 = "103kvf8jry2lwx74z1hwnmw87vhh3x95ppn2xlmq50w9z8zzh161";
      } + "/explain-shell.kak";
      "kak/autoload/change-directory.kak".source = pkgs.fetchFromGitHub {
        owner = "alexherbo2";
        repo = "change-directory.kak";
        rev = "3ae31a18a2ecd5461f526f9ca66e98470fb28ef2";
        sha256 = "0fb8ki3ym5w7d9qfr7vilwjb3n2lazx9y3pal8ddp00k0lwjya08";
      } + "/rc/change-directory.kak";
      "kak/autoload/active-window.kak".source = pkgs.fetchFromGitHub {
        owner = "greenfork";
        repo = "active-window.kak";
        rev = "90213163a06abad4ce60b0ebf1da09eb02882cb7";
        sha256 = "00cvglz0nvpknxbjfg6glcqwmymm9qnjq726kl05nki32fy0hyfz";
      } + "/rc/active-window.kak";
      "kak/autoload/each-line-selection.kak".source = pkgs.fetchFromGitHub {
        owner = "h-youhei";
        repo = "kakoune-each-line-selection";
        rev = "53e15d6f071bfb820c9fd82b972c0fa147dc5100";
        sha256 = "0cbl1v9c8mjhqk8cx22kj3a6lgf7q2jsxwr93dv3vpfvvx6lhkvb";
      } + "/each-line-selection.kak";
      "kak/autoload/close-tag.kak".source = pkgs.fetchFromGitHub {
        owner = "h-youhei";
        repo = "kakoune-close-tag";
        rev = "c719939cef45efbba24d3a6dbcc1aa273bbb8b1a";
        sha256 = "0mfzgkgm0dbyxb7f2ghixlv4ad5kml433c2gpzjk3k1x4vxwz9dw";
      } + "/close-tag.kak";
      "kak/autoload/shellcheck.kak".source = pkgs.fetchFromGitHub {
        owner = "whereswaldon";
        repo = "shellcheck.kak";
        rev = "9acad49508ee95c215541e58353335d9d5b8a927";
        sha256 = "00hyiag96qx74mmp0z0mpysb6x85n6wfb0cy50xnddgxv58pglg4";
      } + "/shellcheck.kak";
      "kak/autoload/rainbow.kak".source = pkgs.fetchFromGitHub {
        owner = "JJK96";
        repo = "kakoune-rainbow";
        rev = "34caf77ce14da52a4d8af6b8893a404605dda62a";
        sha256 = "1fmic508842161zzwmzilljz8p0fanjb15ycqb8hbsjpdy3fwvwi";
      } + "/rainbow.kak";
      "kak/autoload/expand.kak".source = pkgs.fetchFromGitHub {
        owner = "occivink";
        repo = "kakoune-expand";
        rev = "e2c3c31e18a19ef73b8cc31e8b84255e11265689";
        sha256 = "03afg4czqhsh21ig1mczi6jp4vypzjrbif61v2n87371v5zw6xbs";
      } + "/expand.kak";
      "kak/autoload/phantom-selection.kak".source = pkgs.fetchFromGitHub {
        owner = "occivink";
        repo = "kakoune-phantom-selection";
        rev = "a09c5b73525fbfd89a4467f530c975efda722ac6";
        sha256 = "0vhvkpaahwqmdp7cnsjk091d5qh0syx01p43af8rym1klxh9v90i";
      } + "/phantom-selection.kak";
      "kak/autoload/smarttab.kak".source = pkgs.fetchFromGitHub {
        owner = "andreyorst";
        repo = "smarttab.kak";
        rev = "1321c308edac6bd892e2bd2f683432402a04be98";
        sha256 = "048qq8aj405q3zm28jjh6ardxb8ixkq6gs1h3bwdv2qc4zi2nj4g";
      } + "/rc/smarttab.kak";
      "kak/autoload/kakboard.kak".source = pkgs.fetchFromGitHub {
        owner = "lePerdu";
        repo = "kakboard";
        rev = "4cc87b2e2a1cb1e8d61d36de172751e874ff9300";
        sha256 = "06gdz5d5i3c15lhx3r8v88xsvy62q746bmrv122yr0cs8qlmza8i";
      } + "/kakboard.kak";
    };

    home.packages = with pkgs; [
      powerline-fonts
      ripgrep # fzf
      shellcheck
      perl socat # gdb
    ];

    programs.bat.enable = true;
  };
}
