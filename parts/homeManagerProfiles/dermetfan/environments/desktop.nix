{ self, nixosConfig ? null, config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.desktop.enable.default = false;

  config = {
    profiles.dermetfan.environments.media.enable = true;

    programs = {
      timewarrior.enable = true;
      wyrd.enable = true;
      tkremind.enable = true;
      gpg.enable = true;

      volumeicon.enable = config.xsession.enable;

      alacritty.enable = config.profiles.dermetfan.environments.gui.enable &&  config.xsession.enable;
      foot     .enable = config.profiles.dermetfan.environments.gui.enable && !config.xsession.enable;
      geany    .enable = config.profiles.dermetfan.environments.gui.enable;
      firefox  .enable = config.profiles.dermetfan.environments.gui.enable;
      chromium .enable = config.profiles.dermetfan.environments.gui.enable;
      zathura  .enable = config.profiles.dermetfan.environments.gui.enable;

      password-store = {
        enable = true;
        package = (pkgs.pass.override {
          x11Support = config.xsession.enable;
          waylandSupport = config.profiles.dermetfan.environments.gui.enable && !config.xsession.enable;
        }).withExtensions (exts: with exts; [ pass-otp ]);
      };
    };

    xsession.initExtra = ''
      ~/.fehbg || nitrogen --restore
      volumeicon &
    '';

    services = {
      gpg-agent.enable = true;

      blueman-applet        .enable = config.profiles.dermetfan.environments.gui.enable && nixosConfig.hardware.bluetooth.enable or true;

      parcellite            .enable = config.xsession.enable;
      flameshot             .enable = config.xsession.enable;
      dunst                 .enable = config.xsession.enable;
      xscreensaver          .enable = config.xsession.enable;
      network-manager-applet.enable = config.xsession.enable;

      mako.enable = config.profiles.dermetfan.environments.gui.enable && !config.xsession.enable;

      redshift = {
        enable = config.xsession.enable;
        tray = true;
      };
      wlsunset.enable = config.profiles.dermetfan.environments.gui.enable && !config.xsession.enable;
    };

    home.packages = with pkgs; [
      unrar
      unzip
      zip
      weechat
      buku
    ] ++ lib.optionals config.xsession.enable [
      # autostart
      xorg.xmodmap
      nitrogen
    ] ++ lib.optionals config.profiles.dermetfan.environments.gui.enable [
      # autostart
      udevil

      tdesktop
      feh
      gucharmap
      qalculate-gtk
      xarchiver
    ];
  };
}
