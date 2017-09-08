{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.desktop;
in {
  options.config.profiles.desktop.enable = lib.mkEnableOption "desktop programs";

  config = lib.mkIf cfg.enable {
    config = {
      profiles = lib.mkIf (config.config.profiles ? media) {
        media.enable = true;
      };

      programs = {
        geany.enable = true;
        st.enable = true;
      };
    };

    home.packages = with pkgs; [
      gnupg
      htop
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
