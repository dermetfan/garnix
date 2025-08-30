{ nixosConfig ? null, config, lib, ... }:

let
  commonOptions.enableGaps = lib.mkEnableOption "gaps config" // {
    default = true;
  };

  commonConfig = getCfg: let
    cfg = getCfg config;
    profileCfg = getCfg config.profiles.dermetfan;

    inherit (cfg.config) modifier terminal;

    left  = "n";
    right = "o";
    up    = "r";
    down  = "i";
  in lib.mkMerge [
    {
      focus.followMouse = false;

      window = {
        titlebar = false;
        border = 1;
        hideEdgeBorders = "both";
      };

      floating = {
        titlebar = false;
        border = cfg.config.window.border;
      };

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
        statusCommand = "i3status-rs " + config.profiles.dermetfan.programs.i3status-rust.barConfigFiles.default;
        trayOutput = "*";
        colors.background = "00000088";
        extraConfig = ''
          status_padding 0
          colors {
            focused_background 000000CC
          }
        '';
      } ];

      terminal = "alacritty";

      modifier = "Mod4";

      keybindings = let
        floatingMoveStep = "25px";
      in {
        "${modifier}+Return" = "exec ${terminal}";

        "${modifier}+x" = "exec ${terminal} -e ranger";
        "${modifier}+Shift+x" = "exec ${terminal} -e sudo ranger";

        "${modifier}+e"       = "exec rofi -show drun";
        "${modifier}+Shift+e" = "exec rofi -show combi";
        "${modifier}+Tab"     = "exec rofi -show window";

        "${modifier}+m" = lib.mkIf config.programs.networkmanager-dmenu.enable "exec networkmanager_dmenu";

        "${modifier}+q" = "kill";

        "${modifier}+${left}"  = "focus left";
        "${modifier}+${right}" = "focus right";
        "${modifier}+${up}"    = "focus up";
        "${modifier}+${down}"  = "focus down";
        "${modifier}+Left"  = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Up"    = "focus up";
        "${modifier}+Down"  = "focus down";

        "${modifier}+Shift+${left}"  = "move left ${floatingMoveStep}";
        "${modifier}+Shift+${right}" = "move right ${floatingMoveStep}";
        "${modifier}+Shift+${up}"    = "move up ${floatingMoveStep}";
        "${modifier}+Shift+${down}"  = "move down ${floatingMoveStep}";
        "${modifier}+Shift+Left"  = "move left ${floatingMoveStep}";
        "${modifier}+Shift+Right" = "move right ${floatingMoveStep}";
        "${modifier}+Shift+Up"    = "move up ${floatingMoveStep}";
        "${modifier}+Shift+Down"  = "move down ${floatingMoveStep}";

        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+b"       =                         "border toggle";
        "${modifier}+Shift+b" = "[workspace=__focused__] border toggle";

        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+d" = "layout toggle split";

        "${modifier}+h" = "split h";
        "${modifier}+v" = "split v";

        "${modifier}+Shift+space"            = "floating toggle";
        "--whole-window ${modifier}+button2" = "floating toggle";

        "${modifier}+space" = "focus mode_toggle";

        "${modifier}+a" = "focus parent";
        "${modifier}+z" = "focus child";

        "${modifier}+t" = "scratchpad show";
        "${modifier}+Shift+t" = "move scratchpad";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "${modifier}+Ctrl+Left"  = "move workspace to output left";
        "${modifier}+Ctrl+Right" = "move workspace to output right";
        "${modifier}+Ctrl+Up"    = "move workspace to output up";
        "${modifier}+Ctrl+Down"  = "move workspace to output down";

        "${modifier}+Ctrl+${up}"    = "resize grow height 10 px or 10 ppt";
        "${modifier}+Ctrl+${down}"  = "resize shrink height 10 px or 10 ppt";
        "${modifier}+Ctrl+${right}" = "resize grow width 10 px or 10 ppt";
        "${modifier}+Ctrl+${left}"  = "resize shrink width 10 px or 10 ppt";
        "${modifier}+Ctrl+Shift+${up}"    = "resize grow height 1 px or 1 ppt";
        "${modifier}+Ctrl+Shift+${down}"  = "resize shrink height 1 px or 1 ppt";
        "${modifier}+Ctrl+Shift+${right}" = "resize grow width 1 px or 1 ppt";
        "${modifier}+Ctrl+Shift+${left}"  = "resize shrink width 1 px or 1 ppt";
      };
    }

    (let
      modeGaps = "gaps: ${down}|${up} (± inner), ${left}|${right} (± outer), u|l (0 inner/outer), d (default), + Shift (global), b|B (bar)";

      inherit (cfg.config.gaps) inner;
    in lib.mkIf profileCfg.enableGaps {
      gaps = {
        inner = 15;
        smartGaps = true;
        smartBorders = "on";
      };

      keybindings."${modifier}+g" = ''mode "${modeGaps}"; bar hidden_state show'';

      modes.${modeGaps} = {
        ${left} = "gaps outer current minus 5";
        ${right} = "gaps outer current plus 5";
        ${down} = "gaps inner current minus 5";
        ${up} = "gaps inner current plus 5";
        "l" = "gaps outer current set 0";
        "u" = "gaps inner current set 0";
        "d" = "gaps outer current set 0; gaps inner current set ${toString inner}; bar bar-0 gaps 0";
        "b" = "bar bar-0 gaps 0 ${toString inner} ${toString inner} ${toString inner}";

        "Shift+${left}"  = "gaps outer all minus 5";
        "Shift+${up}"    = "gaps inner all plus 5";
        "Shift+${down}"  = "gaps inner all minus 5";
        "Shift+${right}" = "gaps outer all plus 5";
        "Shift+u" = "gaps inner all set 0";
        "Shift+l" = "gaps outer all set 0";
        "Shift+d" = "gaps outer all set 0; gaps inner all set ${toString inner}; bar bar-0 gaps 0";
        "Shift+b" = "bar bar-0 gaps 0";

        "Return" = ''mode "default"; bar hidden_state hide'';
        "Escape" = ''mode "default"; bar hidden_state hide'';
      };
    })
  ];
in

{
  options.profiles.dermetfan = {
    xsession.windowManager.i3   = commonOptions;
    wayland .windowManager.sway = commonOptions;
  };

  config = lib.mkIf (
    config.profiles.dermetfan.xsession.windowManager.i3  .enable ||
    config.profiles.dermetfan.wayland .windowManager.sway.enable
  ) {
    programs = {
      i3status-rust.enable = true;
      alacritty    .enable = true;
      ranger       .enable = true;
      rofi         .enable = true;

      networkmanager-dmenu.enable = nixosConfig.networking.networkmanager.enable or false;
    };

    xsession.windowManager.i3  .config = commonConfig (config: config.xsession.windowManager.i3);
    wayland .windowManager.sway.config = commonConfig (config: config.wayland .windowManager.sway);
  };
}
