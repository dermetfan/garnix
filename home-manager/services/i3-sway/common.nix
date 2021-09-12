{
  nixosConfig, config, lib,
  cfg,
  enableGaps ? true
}:

{
  config.programs = {
    i3status-rust.enable = true;
    alacritty    .enable = true;
    ranger       .enable = true;
    rofi         .enable = true;

    networkmanager-dmenu.enable = nixosConfig.networking.networkmanager.enable or false;
  };

  i3-sway.config = let
    up    = "r";
    down  = "i";
    left  = "n";
    right = "o";
  in lib.mkMerge [
    {
      focus.followMouse = false;

      window = {
        titlebar = false;
        border = 1;
        hideEdgeBorders = "both";
      };

      floating.border = cfg.config.window.border;

      assigns."10" = [
        { class = "^TelegramDesktop$"; }
        { class = "^HipChat$"; }
        { class = "^skypeforlinux$"; }
        { instance = "^WeeChat$"; }
      ];

      bars = [ {
        fonts = cfg.config.fonts;
        mode = "hide";
        workspaceNumbers = false;
        statusCommand = "i3status-rs ${config.config.programs.i3status-rust.barConfigFiles.default}";
        trayOutput = "*";
        colors.background = "00000088";
        extraConfig = ''
          status_padding 0
          colors {
            focused_background 000000CC
          }
        '';
      } ];

      modifier = "Mod4";

      keybindings = let
        mod = cfg.config.modifier;
        floatingMoveStep = "25px";
      in {
        "${mod}+Return" = "exec alacritty";

        "${mod}+x" = "exec alacritty -e ranger";
        "${mod}+Shift+x" = "exec alacritty -e sudo ranger";

        "${mod}+e"            = "exec rofi -show drun";
        "${mod}+Ctrl+e"       = "exec rofi -show run";
        "${mod}+Shift+e"      = "exec rofi -show ssh";
        "${mod}+Ctrl+Shift+e" = "exec rofi -show combi";
        "${mod}+Tab"          = "exec rofi -show window";

        "${mod}+m" = lib.mkIf config.programs.networkmanager-dmenu.enable "exec networkmanager_dmenu";

        "${mod}+q" = "kill";

        "${mod}+${left}"  = "focus left";
        "${mod}+${right}" = "focus right";
        "${mod}+${up}"    = "focus up";
        "${mod}+${down}"  = "focus down";
        "${mod}+Left"  = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up"    = "focus up";
        "${mod}+Down"  = "focus down";

        "${mod}+Shift+${left}"  = "move left ${floatingMoveStep}";
        "${mod}+Shift+${right}" = "move right ${floatingMoveStep}";
        "${mod}+Shift+${up}"    = "move up ${floatingMoveStep}";
        "${mod}+Shift+${down}"  = "move down ${floatingMoveStep}";
        "${mod}+Shift+Left"  = "move left ${floatingMoveStep}";
        "${mod}+Shift+Right" = "move right ${floatingMoveStep}";
        "${mod}+Shift+Up"    = "move up ${floatingMoveStep}";
        "${mod}+Shift+Down"  = "move down ${floatingMoveStep}";

        "${mod}+f" = "fullscreen toggle";

        "${mod}+b"       =                         "border toggle";
        "${mod}+Shift+b" = "[workspace=__focused__] border toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+d" = "layout toggle split";

        "${mod}+h" = "split h";
        "${mod}+v" = "split v";

        "${mod}+Shift+space"            = "floating toggle";
        "--whole-window ${mod}+button2" = "floating toggle";

        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";
        "${mod}+z" = "focus child";

        "${mod}+t" = "scratchpad show";
        "${mod}+Shift+t" = "move scratchpad";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+Ctrl+Left"  = "move workspace to output left";
        "${mod}+Ctrl+Right" = "move workspace to output right";
        "${mod}+Ctrl+Up"    = "move workspace to output up";
        "${mod}+Ctrl+Down"  = "move workspace to output down";

        "${mod}+Ctrl+${up}"    = "resize grow height 10 px or 10 ppt";
        "${mod}+Ctrl+${down}"  = "resize shrink height 10 px or 10 ppt";
        "${mod}+Ctrl+${right}" = "resize grow width 10 px or 10 ppt";
        "${mod}+Ctrl+${left}"  = "resize shrink width 10 px or 10 ppt";
        "${mod}+Ctrl+Shift+${up}"    = "resize grow height 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+${down}"  = "resize shrink height 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+${right}" = "resize grow width 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+${left}"  = "resize shrink width 1 px or 1 ppt";
      };
    }

    (let
      modeGaps = "gaps: i|r (± inner), n|o (± outer), u|l (0 inner/outer), d (default), + Shift (global), b|B (bar)";
    in lib.mkIf enableGaps {
      gaps = {
        inner = 15;
        smartGaps = true;
        smartBorders = "on";
      };

      keybindings."${cfg.config.modifier}+g" = ''mode "${modeGaps}"; bar hidden_state show'';

      modes.${modeGaps} = {
        "n" = "gaps outer current minus 5";
        "o" = "gaps outer current plus 5";
        "i" = "gaps inner current minus 5";
        "r" = "gaps inner current plus 5";
        "l" = "gaps outer current set 0";
        "u" = "gaps inner current set 0";
        "d" = "gaps outer current set 0; gaps inner current set ${toString cfg.config.gaps.inner}; bar bar-0 gaps 0";
        "b" = "bar bar-0 gaps 0 ${toString cfg.config.gaps.inner} ${toString cfg.config.gaps.inner} ${toString cfg.config.gaps.inner}";

        "Shift+${left}"  = "gaps outer all minus 5";
        "Shift+${up}"    = "gaps inner all plus 5";
        "Shift+${down}"  = "gaps inner all minus 5";
        "Shift+${right}" = "gaps outer all plus 5";
        "Shift+u" = "gaps inner all set 0";
        "Shift+l" = "gaps outer all set 0";
        "Shift+d" = "gaps outer all set 0; gaps inner all set ${toString cfg.config.gaps.inner}; bar bar-0 gaps 0";
        "Shift+b" = "bar bar-0 gaps 0";

        "Return" = ''mode "default"; bar hidden_state hide'';
        "Escape" = ''mode "default"; bar hidden_state hide'';
      };
    })
  ];
}
