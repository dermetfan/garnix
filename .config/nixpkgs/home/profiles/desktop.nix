{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.desktop;
in {
  options.config.profiles.desktop.enable = lib.mkEnableOption "desktop programs";

  config = lib.mkIf cfg.enable {
    config = {
      profiles.media.enable = true;

      programs = {
        geany.enable     = config.xsession.enable;
        alacritty.enable = config.xsession.enable;
      };
    };

    home.packages = with pkgs; [
      gnupg
      pass
      unrar
      unzip
      zip
    ] ++ lib.optionals config.xsession.enable [
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
