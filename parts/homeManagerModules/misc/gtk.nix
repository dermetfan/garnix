{ config, lib, pkgs, ... }:

lib.mkIf config.gtk.enable {
  home.sessionVariables.GDK_PIXBUF_MODULE_FILE =
    let
      v2 = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0";
      v2v = builtins.elemAt (
        builtins.attrNames (
          builtins.readDir v2
        )
      ) 0;
    in "${v2}/${v2v}/loaders.cache";
}
