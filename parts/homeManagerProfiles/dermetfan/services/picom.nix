{
  services.picom = {
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
    opacityRule = [
      # https://github.com/i3/i3/issues/1648
      # https://www.reddit.com/r/unixporn/comments/330zxl/webmi3_no_more_overlaying_shadows_and_windows_in/
      "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];

    fade = true;
    fadeDelta = 5;

    blur = true;
    blurExclude = [
      "window_type = 'dock'"
      "window_type = 'desktop'"
      "class_g = 'XScreenSaver'"
      "class_g = 'slop'"
    ];

    vSync = true;

    inactiveDim = "0.2";

    extraOptions = ''
      shadow-radius = 7;
      xinerama-shadow-crop = true;

      blur-kern = "11x11gaussian";

      xrender-sync-fence = true;

      glx-no-stencil = true;
      glx-no-rebind-pixmap = true;

      use-damage = true;
      use-ewmh-active-win = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      focus-exclude = [
        "class_g = 'Cairo-clock'"
      ];

      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;
    '';

    /*
    wintypes: {
      tooltip: {
        fade = true;
        shadow = false;
        opacity = 0.75;
        focus = true;
      };
    };
    */
  };
}
