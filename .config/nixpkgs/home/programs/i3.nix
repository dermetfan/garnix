{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.i3;
in {
  options.config.programs.i3 = {
    enable = with lib; mkOption {
      type = types.bool;
      default = builtins.baseNameOf config.xsession.windowManager.command == "i3";
      description = "Whether to enable i3.";
    };

    enableGaps = with lib; mkOption {
      type = types.bool;
      default = config.xsession.windowManager.command == "${pkgs.i3-gaps}/bin/i3";
      description = "Whether to enable i3-gaps.";
    };
  };

  config = lib.mkIf cfg.enable {
    config.programs = {
      i3status .enable = true;
      alacritty.enable = true;
      ranger   .enable = true;
    };

    programs.rofi.enable = true;

    home = {
      packages = with pkgs; if cfg.enableGaps then [
        i3-gaps
      ] else [
        i3
      ];

      file.".config/i3/config".text = ''
        # This file has been auto-generated by i3-config-wizard(1). It will not be overwritten, so edit it as you like.
        #
        # Should you change your keyboard layout some time, delete this file and re-run i3-config-wizard(1).
        #

        # i3 config file (v4)
        #
        # Please see http://i3wm.org/docs/userguide.html for a complete reference!

        set $mod Mod1

        # Font for window titles. Will also be used by the bar unless a different font is used in the bar {} block below.
        font pango:monospace 8

        # This font is widely installed, provides lots of unicode glyphs, right-to-left text rendering and scalability on retina/hidpi displays (thanks to pango). font pango:DejaVu Sans Mono 8

        # Before i3 v4.8, we used to recommend this one as the default: font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1 The font above is very space-efficient, that is, it looks good, sharp and clear in small sizes. However,
        # its unicode glyph coverage is limited, the old X core fonts rendering does not support right-to-left and this being a bitmap font, it doesn’t scale on retina/hidpi displays.

        # Use Mouse+$mod to drag floating windows to their wanted position
        floating_modifier $mod

        # border on new windows
        new_window pixel 1

        # toggle border
        bindsym $mod+b border toggle
        bindsym $mod+Shift+b [workspace=__focused__] border toggle

        # start a terminal
        bindsym $mod+Return exec alacritty # i3-sensible-terminal

        # kill focused window
        bindsym $mod+c kill

        # start dmenu (a program launcher)
        # bindsym $mod+Shift+e exec --no-startup-id dmenu_run
        # There also is the (new) i3-dmenu-desktop which only displays applications shipping a .desktop file. It is a wrapper around dmenu, so you need that installed.
        # bindsym $mod+Shift+e exec --no-startup-id i3-dmenu-desktop
        # rofi
        bindsym $mod+e exec --no-startup-id rofi -show run
        bindsym $mod+Shift+e exec --no-startup-id rofi -show window

        # focus follows mouse
        focus_follows_mouse no

        # change focus
        bindsym $mod+n focus left
        bindsym $mod+o focus right
        bindsym $mod+r focus up
        bindsym $mod+i focus down

        # alternatively, you can use the arrow keys:
        # bindsym $mod+Left focus left
        # bindsym $mod+Right focus right
        # bindsym $mod+Up focus up
        # bindsym $mod+Down focus down

        # move focused window
        bindsym $mod+Shift+n move left
        bindsym $mod+Shift+o move right
        bindsym $mod+Shift+r move up
        bindsym $mod+Shift+i move down

        # alternatively, you can use the arrow keys:
        # bindsym $mod+Shift+Left move left
        # bindsym $mod+Shift+Right move right
        # bindsym $mod+Shift+Up move up
        # bindsym $mod+Shift+Down move down

        # split in horizontal orientation
        bindsym $mod+h split h

        # split in vertical orientation
        bindsym $mod+v split v

        # enter fullscreen mode for the focused container
        bindsym $mod+f fullscreen toggle

        # change container layout (stacked, tabbed, toggle split)
        bindsym $mod+q layout stacking
        bindsym $mod+w layout tabbed
        bindsym $mod+d layout toggle split

        # toggle tiling / floating
        bindsym $mod+Shift+space floating toggle
        bindsym --whole-window $mod+button2 floating toggle

        # change focus between tiling / floating windows
        bindsym $mod+space focus mode_toggle

        # focus the parent container
        bindsym $mod+a focus parent

        # focus the child container
        bindsym $mod+z focus child

        # scratchpad
        bindsym $mod+t scratchpad show
        bindsym $mod+Shift+t move scratchpad

        # switch to workspace
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9
        bindsym $mod+0 workspace number 10

        # move focused container to workspace
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5
        bindsym $mod+Shift+6 move container to workspace number 6
        bindsym $mod+Shift+7 move container to workspace number 7
        bindsym $mod+Shift+8 move container to workspace number 8
        bindsym $mod+Shift+9 move container to workspace number 9
        bindsym $mod+Shift+0 move container to workspace number 10

        # move current workspace to output
        bindsym $mod+Ctrl+Left move workspace to output left
        bindsym $mod+Ctrl+Right move workspace to output right
        bindsym $mod+Ctrl+Up move workspace to output up
        bindsym $mod+Ctrl+Down move workspace to output down

        # reload the configuration file
        bindsym $mod+k exec "i3-msg reload && timeout 1.75 i3-nagbar -t warning -m 'reloaded i3 configuration'"

        # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
        bindsym $mod+Shift+k exec "i3-msg restart && timeout 1.75 i3-nagbar -t warning -m 'restarted i3 inplace'"

        # exit i3 (logs you out of your X session)
        bindsym $mod+Ctrl+k exec "i3-nagbar -t warning -m 'Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"

        # Pressing left will shrink the window’s width. Pressing right will grow the window’s width. Pressing up will grow the window’s height. Pressing down will shrink the window’s height.
        bindsym $mod+Ctrl+n resize shrink width 10 px or 10 ppt
        bindsym $mod+Ctrl+o resize grow width 10 px or 10 ppt
        bindsym $mod+Ctrl+r resize shrink height 10 px or 10 ppt
        bindsym $mod+Ctrl+i resize grow height 10 px or 10 ppt

        # same bindings with Shift for precise control
        bindsym $mod+Ctrl+Shift+n resize shrink width 1 px or 1 ppt
        bindsym $mod+Ctrl+Shift+o resize grow width 1 px or 1 ppt
        bindsym $mod+Ctrl+Shift+r resize shrink height 1 px or 1 ppt
        bindsym $mod+Ctrl+Shift+i resize grow height 1 px or 1 ppt

        # same bindings, but for the arrow keys
        # bindsym $mod+Ctrl+Left resize grow width 10 px or 10 ppt
        # bindsym $mod+Ctrl+Right resize shrink width 10 px or 10 ppt
        # bindsym $mod+Ctrl+Up resize grow height 10 px or 10 ppt
        # bindsym $mod+Ctrl+Down resize shrink height 10 px or 10 ppt

        # Start i3bar to display a workspace bar (plus the system information i3status finds out, if available)
        bar {
            mode hide
            modifier $mod
            strip_workspace_numbers yes
            status_command i3status
            font pango:monospace 11
            separator_symbol " | "
            tray_output primary
        }

        # show applications on certain workspaces
        assign [class="^TelegramDesktop$"] 10
        assign [class="^HipChat$"] 10
        assign [class="^Skype$"] 10

        # application shortcuts
        bindsym $mod+x exec alacritty -e ranger
        bindsym $mod+Shift+x exec sudo alacritty -e ranger
      '' + lib.optionalString cfg.enableGaps ''
        # gaps
        gaps inner 15
        smart_gaps on
        smart_borders on

        set $mode_gaps gaps: i|r (± inner), n|o (± outer), u|l (0 inner/outer), d (default), + Shift (global)
        bindsym $mod+g mode "$mode_gaps"; bar hidden_state show
        mode "$mode_gaps" {
            bindsym n gaps outer current minus 5
            bindsym o gaps outer current plus 5
            bindsym i gaps inner current minus 5
            bindsym r gaps inner current plus 5
            bindsym l gaps outer current set 0
            bindsym u gaps inner current set 0
            bindsym d gaps outer current set 0; gaps inner current set 15

            bindsym Shift+n gaps outer all minus 5
            bindsym Shift+o gaps outer all plus 5
            bindsym Shift+i gaps inner all minus 5
            bindsym Shift+r gaps inner all plus 5
            bindsym Shift+l gaps outer all set 0
            bindsym Shift+u gaps inner all set 0
            bindsym Shift+d gaps outer all set 0; gaps inner all set 15

            bindsym Return mode "default"; bar hidden_state hide
            bindsym Escape mode "default"; bar hidden_state hide
        }
      '';
    };
  };
}
