{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      gtk_engines
      gtk-engine-murrine
      xfce.gtk_xfce_engine

      adapta-gtk-theme
      arc-theme
      arc-icon-theme
      clearlooks-phenix
      elementary-icon-theme
      faba-icon-theme
      flat-plat
      gnome2.gnome_icon_theme
      gnome3.adwaita-icon-theme
      gnome3.gnome_themes_standard
      gnome-breeze
      greybird
      hicolor_icon_theme
      kde4.oxygen_icons
      mate.mate-themes
      mate.mate-icon-theme
      mate.mate-icon-theme-faenza
      moka-icon-theme
      numix-gtk-theme
      numix-icon-theme
      numix-icon-theme-circle
      oxygen-gtk2
      oxygen-gtk3
      paper-gtk-theme
      paper-icon-theme
      tango-icon-theme
      theme-vertex
      vanilla-dmz
      xfce.xfce4icontheme
      zuki-themes
    ];

    variables = {
      GTK_DATA_PREFIX = "/run/current-system/sw";
    };

    pathsToLink = [
      "/share"
    ];
  };

  services.xserver.displayManager.sessionCommands = ''
    export GDK_PIXBUF_MODULE_FILE=`echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache`
  '';

  nixpkgs.config.packageOverrides = pkgs: rec {
    qt4 = pkgs.qt4.override {
      gtkStyle = true;
    };
    qt5.base = pkgs.qt5.base.override {
      gtkStyle = true;
    };
  };
}
