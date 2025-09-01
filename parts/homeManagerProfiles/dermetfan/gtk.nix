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
    package = pkgs.kdePackages.breeze-gtk;
    name = nameByPolarity "Breeze" "Breeze-Dark" true;
  };
}
