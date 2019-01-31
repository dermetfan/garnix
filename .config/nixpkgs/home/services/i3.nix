{ config, lib, pkgs, ... }:

let
  cfg = config.config.services.i3;
in {
  options.config.services.i3.enable = with lib; mkOption {
    type = types.bool;
    default = config.xsession.enable && config.xsession.windowManager.i3.enable;
    description = "Whether to configure i3.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      i3status-rust.enable = true;
      alacritty.enable = true;
      ranger.enable = true;
      rofi.enable = true;
    };

    xsession.windowManager.i3.config = let
      modeGaps = "gaps: i|r (± inner), n|o (± outer), u|l (0 inner/outer), d (default), + Shift (global)";
    in {
      focus.followMouse = false;

      window = {
        titlebar = false;
        border = 1;
        hideEdgeBorders = "both";
      };

      assigns."10" = [
        { class = "^TelegramDesktop$"; }
        { class = "^HipChat$"; }
        { class = "^skypeforlinux$"; }
        { instance = "^WeeChat$"; }
      ];

      bars = [ {
        mode = "hide";
        fonts = [ "pango:monospace 11" ];
        workspaceNumbers = false;
        statusCommand = "i3status-rs ${config.config.programs.i3status-rust.configFile}";
      } ];

      modifier = "Mod4";

      keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in {
        "${mod}+Return" = "exec alacritty";

        "${mod}+x" = "exec alacritty -e ranger";
        "${mod}+Shift+x" = "exec sudo alacritty -e ranger";

        "${mod}+e"            = "exec rofi -show drun";
        "${mod}+Ctrl+e"       = "exec rofi -show run";
        "${mod}+Shift+e"      = "exec rofi -show ssh";
        "${mod}+Ctrl+Shift+e" = "exec rofi -show combi";
        "${mod}+Tab"          = "exec rofi -show window";

        "${mod}+q" = "kill";

        "${mod}+n" = "focus left";
        "${mod}+o" = "focus right";
        "${mod}+r" = "focus up";
        "${mod}+i" = "focus down";
        "${mod}+Left"  = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up"    = "focus up";
        "${mod}+Down"  = "focus down";

        "${mod}+Shift+n" = "move left";
        "${mod}+Shift+o" = "move right";
        "${mod}+Shift+r" = "move up";
        "${mod}+Shift+i" = "move down";
        "${mod}+Shift+Left"  = "move left";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+Up"    = "move up";
        "${mod}+Shift+Down"  = "move down";

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

        "${mod}+k" = ''exec "i3-msg reload && timeout 1.75 i3-nagbar -t warning -m 'reloaded i3 configuration'"'';
        "${mod}+Shift+k" = ''exec "i3-msg restart && timeout 1.75 i3-nagbar -t warning -m 'restarted i3 inplace'"'';
        "${mod}+Ctrl+k" = ''exec "i3-nagbar -t warning -m 'Exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';

        "${mod}+Ctrl+n" = "resize shrink width 10 px or 10 ppt";
        "${mod}+Ctrl+r" = "resize grow height 10 px or 10 ppt";
        "${mod}+Ctrl+i" = "resize shrink height 10 px or 10 ppt";
        "${mod}+Ctrl+o" = "resize grow width 10 px or 10 ppt";
        "${mod}+Ctrl+Shift+n" = "resize shrink width 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+r" = "resize grow height 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+i" = "resize shrink height 1 px or 1 ppt";
        "${mod}+Ctrl+Shift+o" = "resize grow width 1 px or 1 ppt";

        "${mod}+g" = ''mode "${modeGaps}"; bar hidden_state show'';
      };

      modes.${modeGaps} = {
        "n" = "gaps outer current minus 5";
        "o" = "gaps outer current plus 5";
        "i" = "gaps inner current minus 5";
        "r" = "gaps inner current plus 5";
        "l" = "gaps outer current set 0";
        "u" = "gaps inner current set 0";
        "d" = "gaps outer current set 0; gaps inner current set 15";

        "Shift+n" = "gaps outer all minus 5";
        "Shift+r" = "gaps inner all plus 5";
        "Shift+i" = "gaps inner all minus 5";
        "Shift+o" = "gaps outer all plus 5";
        "Shift+u" = "gaps inner all set 0";
        "Shift+l" = "gaps outer all set 0";
        "Shift+d" = "gaps outer all set 0; gaps inner all set 15";

        "Return" = ''mode "default"; bar hidden_state hide'';
        "Escape" = ''mode "default"; bar hidden_state hide'';
      };
    };
  };
}
