{ lib, config, pkgs, ... }:

let
  # Override stylix without forcing.
  mkPreferred = lib.mkOverride (lib.modules.defaultOverridePriority - 1);

  nameByPolarity = light: dark: defaultDark: {
    inherit light dark;
    either = if defaultDark then dark else light;
  }.${config.stylix.polarity or "either"};
in {
  # Stylix always sets Adwaita.
  gtk.theme = mkPreferred {
    # These are all nice so I'll keep them here for later.

    breeze = {
      package = pkgs.kdePackages.breeze-gtk;
      name = nameByPolarity "Breeze" "Breeze-Dark" true;
    };

    colloid = {
      package = pkgs.colloid-gtk-theme.override {
        themeVariants = [ "orange" ];
        colorVariants = [ (nameByPolarity "light" "dark" true) ];
        sizeVariants = [ "compact" ];
        tweaks = [ "gruvbox" "black" "normal" ];
      };
      name = "Colloid-Orange-${nameByPolarity "Light" "Dark" true}-Compact-Gruvbox";
    };

    gruvbox = {
      package = pkgs.gruvbox-gtk-theme.override {
        themeVariants = [ "orange" ];
        colorVariants = [ (nameByPolarity "light" "dark" true) ];
        sizeVariants = [ "compact" ];
        tweakVariants = [ "black" "outline" "float" ];
      };
      name = "Gruvbox-Orange-${nameByPolarity "Light" "Dark" true}-Compact";
    };
  }.gruvbox;
}
