{ nixosConfig ? null, config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.desktop.enable.default = false;

  config = {
    profiles.dermetfan.environments.media.enable = true;

    programs = {
      timewarrior.enable = true;
      wyrd.enable = true;
      tkremind.enable = true;
      gpg.enable = true;

      foot     .enable = config.profiles.dermetfan.environments.gui.enable;
      geany    .enable = config.profiles.dermetfan.environments.gui.enable;
      firefox  .enable = config.profiles.dermetfan.environments.gui.enable;
      chromium .enable = config.profiles.dermetfan.environments.gui.enable;
      zathura  .enable = config.profiles.dermetfan.environments.gui.enable;

      password-store = {
        enable = true;
        package = (pkgs.pass.override {
          waylandSupport = config.profiles.dermetfan.environments.gui.enable;
        }).withExtensions (exts: with exts; [ pass-otp ]);
      };
    };

    services = {
      gpg-agent.enable = true;

      blueman-applet        .enable = config.profiles.dermetfan.environments.gui.enable && nixosConfig.hardware.bluetooth.enable or true;

      mako.enable = config.profiles.dermetfan.environments.gui.enable;

      wlsunset.enable = config.profiles.dermetfan.environments.gui.enable;
    };

    home.packages = with pkgs; [
      unrar
      unzip
      zip
      weechat
      buku
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
