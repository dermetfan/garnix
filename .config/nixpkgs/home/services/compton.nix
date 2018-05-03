{ config, lib, pkgs, ... }:

let
  cfg = config.config.services.compton;
in {
  options.config.services.compton.enable = with lib; mkOption {
    type = types.bool;
    default = config.services.compton.enable;
    defaultText = "<option>services.compton.enable</option>";
    description = "Whether to configure compton.";
  };

  config.services.compton = lib.mkIf cfg.enable {
    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowOpacity = "0.7";
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "class_g = 'Dunst'"
      "class_g = 'slop'"
    ];

    menuOpacity = "0.8";

    fade = true;
    fadeDelta = 5;

    vSync = "opengl-swc";

    extraOptions = ''
      no-dnd-shadow = true;
      no-dock-shadow = true;
      clear-shadow = true;
      shadow-radius = 7;
      xinerama-shadow-crop = true;

      alpha-step = 0.06;

      blur-background = true;
      blur-background-exclude = [
        "window_type = 'dock'",
        "window_type = 'desktop'",
        "class_g = 'XScreenSaver'",
        "class_g = 'slop'"
      ];
      blur-kern = "11x11gaussian";

      xrender-sync = true;
      xrender-sync-fence = true;

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
}
