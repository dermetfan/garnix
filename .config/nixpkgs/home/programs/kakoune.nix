{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.kakoune;
in {
  options.config.programs.kakoune.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.kakoune.enable;
    defaultText = "<option>config.programs.kakoune.enable</option>";
    description = "Whether to configure kakoune.";
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
        keyMappings = [
          {
            docstring = "case insensitive search";
            mode = "user";
            key = "/";
            effect = "/(?i)";
          }
          {
            docstring = "case insensitive backward search";
            mode = "user";
            key = "<a-/>";
            effect = "<a-/>(?i)";
          }
          {
            docstring = "case insensitive extend search";
            mode = "user";
            key = "?";
            effect = "?(?i)";
          }
          {
            docstring = "case insensitive backward extend search";
            mode = "user";
            key = "<a-?>";
            effect = "<a-?>(?i)";
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
        ];
        hooks = [
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
      '';
    };

    xdg.configFile = with pkgs.kakounePlugins; {
      "kak/autoload" = {
        source = "${pkgs.kakoune-unwrapped}/share/kak/autoload";
        recursive = true;
      };
      "kak/autoload/auto-pairs".source = kak-auto-pairs;
      "kak/autoload/buffers".source = kak-buffers;
      "kak/autoload/powerline".source = kak-powerline;
      "kak/autoload/fzf".source = kak-fzf;
      "kak/autoload/state-save".source = pkgs.fetchFromGitLab {
        owner = "Screwtapello";
        repo = "kakoune-state-save";
        rev = "ab7c0c765326a4a80af78857469ee8c80814c52a";
        sha256 = "1q53b1pw0mi1q8h5xv1wxqsj9fa9081r7r6ry1y6vp6q8hdq40q0";
      };
    };

    home.packages = with pkgs; [
      powerline-fonts
      ripgrep
    ];

    programs.bat.enable = true;
  };
}
