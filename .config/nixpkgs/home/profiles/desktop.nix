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
      gpg.enable = true;

      volumeicon.enable = config.xsession.enable;

      alacritty.enable = config.profiles.gui.enable;
      geany    .enable = config.profiles.gui.enable;
      firefox  .enable = config.profiles.gui.enable;
      chromium .enable = config.profiles.gui.enable;
      zathura  .enable = config.profiles.gui.enable;

      mako.enable = config.profiles.gui.enable && !config.xsession.enable;

      password-store = {
        enable = true;
        package = (pkgs.pass.override {
          x11Support = config.xsession.enable;
          waylandSupport = config.profiles.gui.enable && !config.xsession.enable;
        }).withExtensions (exts: with exts; [ pass-otp ]);
      };
    };

    xsession.initExtra = ''
      ~/.fehbg || nitrogen --restore
      volumeicon &
    '';

    services = {
      gpg-agent.enable = true;

      blueman-applet        .enable = config.profiles.gui.enable && sysCfg.hardware.bluetooth.enable or true;
      network-manager-applet.enable = config.profiles.gui.enable;
      rsibreak              .enable = config.profiles.gui.enable;

      parcellite  .enable = config.xsession.enable;
      flameshot   .enable = config.xsession.enable;
      dunst       .enable = config.xsession.enable;
      xscreensaver.enable = config.xsession.enable;

      redshift = {
        enable = config.profiles.gui.enable;
        tray = true;
      };
    };

    home.packages = with pkgs; [
      unrar
      unzip
      zip
      weechat
      buku
      neuron-zettelkasten
    ] ++ lib.optionals config.xsession.enable [
      # autostart
      xorg.xmodmap
      nitrogen
    ] ++ lib.optionals config.profiles.gui.enable [
      # autostart
      udevil

      tdesktop
      skype
      feh
      gucharmap
      qalculate-gtk
      xarchiver
    ];
  };
}
