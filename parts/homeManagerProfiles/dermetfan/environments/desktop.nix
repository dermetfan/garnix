{ nixosConfig ? null, config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.desktop.enable.default = false;

  config = {
    profiles.dermetfan.environments.media.enable = true;

    programs = {
      wyrd.enable = true;
      tkremind.enable = true;
      gpg.enable = true;

      foot     .enable = config.profiles.dermetfan.environments.gui.enable;
      geany    .enable = config.profiles.dermetfan.environments.gui.enable;
      firefox  .enable = config.profiles.dermetfan.environments.gui.enable;
      chromium .enable = config.profiles.dermetfan.environments.gui.enable;
      zathura  .enable = config.profiles.dermetfan.environments.gui.enable;
    };

    services = {
      gpg-agent.enable = true;

      blueman-applet.enable = config.profiles.dermetfan.environments.gui.enable && nixosConfig.hardware.bluetooth.enable or true;

      mako.enable = config.profiles.dermetfan.environments.gui.enable;

      wlsunset.enable = config.profiles.dermetfan.environments.gui.enable;
    };

    home.packages = with pkgs; [
      gopass
      unrar
      unzip
      zip
      weechat
      buku
    ] ++ lib.optionals config.profiles.dermetfan.environments.gui.enable [
      # autostart
      udevil

      telegram-desktop
      feh
      gucharmap
      qalculate-gtk
      xarchiver
    ];
  };
}
