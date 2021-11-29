{ config, lib, pkgs, ... }:

let
  cfg = config.config.services.dunst;
in {
  options.config.services.dunst.enable = with lib; mkOption {
    type = types.bool;
    default = config.services.dunst.enable;
    defaultText = "<option>services.dunst.enable</option>";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      rofi.enable = true;
      firefox.enable = true;
    };

    services.dunst.settings = {
      global = {
        font = "Monospace 8";
        allow_markup = true;
        format = "<b>%s</b>\\n%b\\n%p";
        sort = true;
        indicate_hidden = true;
        alignment = "left";
        bounce_freq = 0;
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        geometry = "300x5-30+20";
        shrink = false;
        transparency = 15;
        idle_threshold = 120;
        monitor = 0;
        follow = "mouse";
        sticky_history = true;
        history_length = 20;
        show_indicators = true;
        line_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        separator_color = "frame";
        startup_notification = false;
        dmenu = "rofi -dmenu -p dunst:";
        browser = "firefox -new-tab";
        icon_position = "off";
      };

      frame = {
        width = 3;
        color = "#aaaaaa";
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };

      urgency_low = {
        background = "#222222";
        foreground = "#888888";
        timeout = 10;
      };

      urgency_normal = {
        background = "#285577";
        foreground = "#ffffff";
        timeout = 10;
      };

      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
        timeout = 0;
      };
    };
  };
}
