{ pkgs, ... }:

{
  gtk = {
    theme = {
      name = "Vertex-Dark";
      package = pkgs.theme-vertex;
    };
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
  };
}
