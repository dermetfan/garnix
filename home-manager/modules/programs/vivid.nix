{ config, lib, pkgs, ... }:

let
  themes = {
    # https://github.com/cydmium/cydots/commit/8516a98d6c01270b86724ef5a55bc1843d9f5704#diff-ec6f51d8816fb365f1d9a108a6416bb947d7bad9d7fb2c1e1093c3a63fbbc9b1
    gruvbox = {
      colors = {
        background = "282828";
        darkred = "cc241d";
        darkgreen = "98971a";
        darkyellow = "d79921";
        darkblue = "458588";
        darkpurple = "b16286";
        darkcyan = "689d6a";
        darkgray = "928374";
        darkorange = "d65d0e";
        gray = "a89984";
        red = "fb4934";
        green = "b8bb26";
        yellow = "fabd2f";
        blue = "83a598";
        purple = "d3869b";
        cyan = "8ec07c";
        foreground = "ebdbb2";
        orange = "fe8019";
        white = "ffffff";
        black = "1d2021";
        gold = "b3a369";
        khaki = "f0e68c";
        dimgray = "504945";
        brightgreen = "93bb26";
      };
      core = {
        regular_file = {};
        directory.foreground = "blue";
        executable_file = {
          foreground = "green";
          font-style = "bold";
        };
        symlink.foreground = "purple";
        broken_symlink = {
          foreground = "black";
          background = "red";
        };
        missing_symlink_target = {
          foreground = "black";
          background = "red";
        };
        fifo = {
          foreground = "black";
          background = "cyan";
        };
        socket = {
          foreground = "black";
          background = "purple";
        };
        character_device = {
          foreground = "purple";
          background = "darkgray";
        };
        block_device = {
          foreground = "cyan";
          background = "darkgray";
        };
        normal_text = {};
        sticky = {};
        sticky_other_writable = {};
        other_writable = {};
      };
      text = {
        special = {
          foreground = "background";
          background = "khaki";
        };
        todo.font-style = "bold";
        licenses.foreground = "gray";
        configuration.foreground = "purple";
        other.foreground = "darkyellow";
      };
      markup.foreground = "gold";
      programming = {
        source.foreground = "yellow";
        tooling = {
          foreground = "foreground";
          continuous-integration.foreground = "khaki";
        };
      };
      media.foreground = "orange";
      office.foreground = "khaki";
      archives = {
        foreground = "red";
        font-style = "underline";
      };
      executable = {
        foreground = "brightgreen";
        font-style = "bold";
      };
      unimportant.foreground = "dimgray";
    };

    # https://github.com/sharkdp/vivid/pull/39/files
    gruvbox-dark = {
      colors = {
        dark_bg0_hard = "1d2021";
        dark_bg0 = "282828";
        dark_bg0_soft = "32302f";
        dark_bg1 = "3c3836";
        dark_bg2 = "504945";
        dark_bg3 = "665c54";
        dark_bg4 = "7c6f64";
        dark_bg = "282828";
        dark_fg0 = "fbf1c7";
        dark_fg1 = "eddbb2";
        dark_fg2 = "d5c4a1";
        dark_fg3 = "bdae93";
        dark_fg4 = "a89984";
        dark_fg = "eddbb2";
        gray_245 = "928374";
        gray_244 = "928374";
        light_bg0_hard = "f9f5d7";
        light_bg0 = "fbf1c7";
        light_bg0_soft = "f2e5bc";
        light_bg1 = "ebdbb2";
        light_bg2 = "d5c4a1";
        light_bg3 = "bdae93";
        light_bg4 = "a89984";
        light_bg = "fbf1c7";
        light_fg0 = "282828";
        light_fg1 = "3c3836";
        light_fg2 = "504945";
        light_fg3 = "665c54";
        light_fg4 = "7c6f64";
        light_fg = "3c3836";
        bright_red = "fb4934";
        bright_green = "b8bb26";
        bright_yellow = "fabd2f";
        bright_blue = "83a598";
        bright_purple = "d3869b";
        bright_aqua = "8ec07c";
        bright_orange = "fe8019";
        neutral_red = "cc241d";
        neutral_green = "98971a";
        neutral_yellow = "d79921";
        neutral_blue = "458588";
        neutral_purple = "b16286";
        neutral_aqua = "689d6a";
        neutral_orange = "d65d0e";
        faded_red = "9d0006";
        faded_green = "79740e";
        faded_yellow = "b57614";
        faded_blue = "076678";
        faded_purple = "8f3f71";
        faded_aqua = "427b58";
        faded_orange = "af3a03";
      };
      core = {
        normal_text = {};
        regular_file = {};
        reset = {};
        directory.foreground = "neutral_blue";
        symlink.foreground = "neutral_purple";
        multi_hard_link = {};
        fifo = {
          foreground = "bright_aqua";
          font-style = "bold";
        };
        socket = {
          foreground = "bright_green";
          font-style = "bold";
        };
        door = {
          foreground = "bright_red";
          font-style = "bold";
        };
        block_device = {
          foreground = "bright_yellow";
          font-style = "bold";
        };
        character_device.foreground = "neutral_yellow";
        broken_symlink = {
          foreground = "dark_bg";
          background = "neutral_purple";
        };
        missing_symlink_target = {
          foreground = "neutral_red";
          font-style = "italic";
        };
        setuid = {
          foreground = "bright_red";
          font-style = "bold";
        };
        setgid = {
          foreground = "bright_red";
          font-style = "bold";
        };
        file_with_capability = {
          foreground = "bright_red";
          font-style = "bold";
        };
        sticky_other_writable = {
          foreground = "bright_blue";
          font-style = "bold";
        };
        other_writable = {
          foreground = "neutral_blue";
          font-style = "italic";
        };
        sticky = {
          foreground = "bright_blue";
          font-style = "bold";
        };
        executable_file = {
          foreground = "bright_green";
          font-style = "bold";
        };
      };
      text = {
        special = {
          foreground = "bright_yellow";
          font-style = "bold";
        };
        todo.foreground = "bright_green";
        licenses = {
          foreground = "dark_fg0";
          font-style = "italic";
        };
        configuration.foreground = "bright_yellow";
        other.foreground = "dark_fg";
      };
      markup.foreground = "neutral_yellow";
      programming = {
        source.foreground = "neutral_green";
        tooling = {
          foreground = "bright_blue";
          font-style = "italic";
          continuous-integration.foreground = "bright_blue";
        };
      };
      media = {
        foreground = "neutral_aqua";
        video = {
          foreground = "bright_aqua";
          font-style = "bold";
        };
      };
      office = {
        foreground = "bright_blue";
        font-style = "bold";
      };
      archives = {
        foreground = "neutral_orange";
        images = {
          foreground = "bright_orange";
          font-style = "bold";
        };
      };
      executable = {
        foreground = "bright_green";
        font-style = "bold";
      };
      unimportant = {
        foreground = "dark_bg3";
        font-style = "italic";
      };
    };
  };

  cfg = config.programs.vivid;
in {
  options.programs.vivid = with lib; {
    enable = mkEnableOption "set LS_COLORS";
    theme = mkOption {
      type = types.str;
      default = "gruvbox";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.LS_COLORS = lib.fileContents (
      pkgs.runCommand "vivid-LS_COLORS" {
        theme = builtins.toJSON themes.${cfg.theme};
        passAsFile = [ "theme" ];
      } ''
        HOME=.home
        mkdir -p $HOME/.config/vivid/themes
        ln -s $themePath $HOME/.config/vivid/themes/theme.yml
        ${pkgs.vivid}/bin/vivid generate theme > $out
      ''
    );
  };
}
