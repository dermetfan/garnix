{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.compton;
in {
  options.config.programs.compton.enable = lib.mkEnableOption "compton";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.compton ];

      file.".config/compton.conf".text = ''
        shadow = true;
        no-dnd-shadow = true;
        no-dock-shadow = true;
        clear-shadow = true;
        shadow-radius = 7;
        shadow-offset-x = -7;
        shadow-offset-y = -7;
        shadow-opacity = 0.7;
        shadow-exclude = [
          "name = 'Notification'",
          "class_g = 'Conky'",
          "class_g ?= 'Notify-osd'",
          "class_g = 'Cairo-clock'",
          "class_g = 'Dunst'",
          "class_g = 'slop'"
        ];

        fading = true;
        fade-delta = 5;

        menu-opacity = 0.8;

        alpha-step = 0.06;

        blur-background = true;
        blur-background-exclude = [
          "window_type = 'dock'",
          "window_type = 'desktop'",
          "class_g = 'XScreenSaver'",
          "class_g = 'slop'"
        ];
        blur-kern = "7x7box";

        xrender-sync = true;
        xrender-sync-fence = true;

        backend = "glx";
        vsync = "opengl-swc";
        paint-on-overlay = true;

        inactive-dim = 0.2;

        use-ewmh-active-win = true;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
        focus-exclude = [
          "class_g = 'Cairo-clock'"
        ];

        detect-client-opacity = true;
        detect-transient = true;
        detect-client-leader = true;

        wintypes: {
          tooltip: {
            fade = true;
            shadow = false;
            opacity = 0.75;
            focus = true;
          };
        };

        # https://github.com/i3/i3/issues/1648
        # https://www.reddit.com/r/unixporn/comments/330zxl/webmi3_no_more_overlaying_shadows_and_windows_in/
        opacity-rule = [
          "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
        ];
      '';
    };
  };
}
