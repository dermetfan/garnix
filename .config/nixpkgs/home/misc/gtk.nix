{ config, lib, pkgs, ... }:

lib.mkIf (config.xsession.enable && config.gtk.enable) {
  gtk = {
    enable = config.xsession.enable;
    theme = {
      name = "Vertex-Dark";
      package = pkgs.theme-vertex;
    };
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
  };

  home = {
    file.".config/gtk-3.0/bookmarks".text = ''
      file:///data/dermetfan
    '';

    sessionVariables.GDK_PIXBUF_MODULE_FILE =
      let
        v2 = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0";
        v2v = builtins.elemAt (
          builtins.attrNames (
            builtins.readDir v2
          )
        ) 0;
      in "${v2}/${v2v}/loaders.cache";
  };
}
