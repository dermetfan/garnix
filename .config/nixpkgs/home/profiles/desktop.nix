{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.desktop;
  sysCfg = config.passthru.systemConfig or null;
in {
  options.profiles.desktop.enable = lib.mkEnableOption "desktop programs";

  config = lib.mkIf cfg.enable {
    profiles.media.enable = true;

    programs = {
      taskwarrior.enable = true;
      timewarrior.enable = true;

      volumeicon.enable = config.xsession.enable;
      alacritty .enable = config.xsession.enable;
      geany     .enable = config.xsession.enable;
      firefox   .enable = config.xsession.enable;
      chromium  .enable = config.xsession.enable;
      zathura   .enable = config.xsession.enable;

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
      blueman-applet        .enable = config.xsession.enable && sysCfg.hardware.bluetooth.enable or true;
      dunst                 .enable = config.xsession.enable;
      network-manager-applet.enable = config.xsession.enable;
      parcellite            .enable = config.xsession.enable;
      xscreensaver          .enable = config.xsession.enable;
      rsibreak              .enable = config.xsession.enable;
      flameshot             .enable = config.xsession.enable;
      redshift = {
        enable = config.xsession.enable;
        tray = true;
      };
    };

    xsession = {
      windowManager.i3.enable = true;
      initExtra = ''
        xset r rate 225 27
        xset m 5 1
        devmon &
        syndaemon -d -i 0.625 -K -R || :

        ~/.fehbg || nitrogen --restore
        volumeicon &
      '';
    };

    gtk.enable = config.xsession.enable;

    home.packages = with pkgs; [
      gnupg
      (pass.withExtensions (exts: with exts; [ pass-otp ]))
      unrar
      unzip
      zip
      weechat
    ] ++ lib.optionals config.xsession.enable [
      # autostart
      xorg.xmodmap
      udevil
      nitrogen

      tdesktop
      skype
      feh
      gucharmap
      qalculate-gtk
      xarchiver
    ];
  };
}
