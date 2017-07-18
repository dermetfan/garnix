{ config, pkgs, ... }:

let
  settings = {
    gtkStyle = true;
  } // config.passthru.gtk or {};
in {
  environment = {
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

  nixpkgs.config.packageOverrides = pkgs: {
    qt4 = pkgs.qt4.override {
      gtkStyle = settings.gtkStyle;
    };
  };
}
