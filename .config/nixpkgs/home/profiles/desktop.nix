{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.desktop;
  sysCfg = config.passthru.systemConfig or null;
in {
  options.config.profiles.desktop.enable = lib.mkEnableOption "desktop programs";

  config = lib.mkIf cfg.enable {
    config = {
      profiles.media.enable = true;

      programs = {
        parcellite  .enable = config.xsession.enable;
        volumeicon  .enable = config.xsession.enable;
        xscreensaver.enable = config.xsession.enable;

        geany       .enable = config.xsession.enable;
        alacritty   .enable = config.xsession.enable;
      };
    };

    programs = {
      firefox.enable = config.xsession.enable;

      browserpass = {
        enable = true;
        browsers = [
          "vivaldi"
          "chromium"
          "firefox"
        ];
      };
    };

    services = {
      blueman-applet.enable         = config.xsession.enable && sysCfg.hardware.bluetooth.enable or true;
      dunst.enable                  = config.xsession.enable;
      network-manager-applet.enable = config.xsession.enable;
      xscreensaver.enable           = config.xsession.enable;
    };

    xsession = {
      windowManager.command = "${pkgs.i3-gaps}/bin/i3";
      initExtra = ''
        xmodmap -e "keycode 66 = Caps_Lock"
        xflux -l 51.165691 -g 10.45152000000058
        xset r rate 225 27
        xset m 5 1
        devmon &
        syndaemon -d -i 0.625 -K -R || :

        ~/.fehbg || nitrogen --restore
        volumeicon &
        telegram-desktop &
        hipchat &
        skypeforlinux &
      '';
    };

    gtk.enable = config.xsession.enable;

    home.packages = with pkgs; [
      gnupg
      pass
      unrar
      unzip
      zip
    ] ++ lib.optionals config.xsession.enable [
      # autostart
      xorg.xmodmap
      xflux
      udevil
      tdesktop
      hipchat
      nitrogen
      skype

      chromium
      feh
      qalculate-gtk
      rss-glx
      vivaldi
      xarchiver
      zathura
    ];
  };
}
