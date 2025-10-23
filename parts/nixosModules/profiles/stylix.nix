{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.stylix;
in {
  imports = with inputs; [
    stylix.nixosModules.stylix
  ];

  options.profiles.stylix.enable = lib.mkEnableOption "stylix settings";

  config.stylix = lib.mkIf cfg.enable {
    enable = true;

    base16Scheme = pkgs.base16-schemes + /share/themes/gruvbox-dark-hard.yaml;
    image = inputs.gruvbox-wallpapers + /forest-hut.png;
    polarity = "dark";

    fonts = {
      sizes.desktop = config.stylix.fonts.sizes.applications;

      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
    };

    icons = {
      enable = true;
    } // {
      # These are all nice so I'll keep them here for later.

      breeze = rec {
        package = pkgs.kdePackages.breeze-icons;
        light = "breeze";
        dark = light + "-dark";
      };

      colloid = {
        package = pkgs.colloid-icon-theme.override {
          schemeVariants = [ "gruvbox" ];
          colorVariants = [ "orange" ];
        };
        light = "Colloid-Orange-Gruvbox-Light";
        dark  = "Colloid-Orange-Gruvbox-Dark";
      };

      gruvbox = {
        package = pkgs.gruvbox-plus-icons.override {
          folder-color = "orange";
        };
        dark = "Gruvbox-Plus-Dark";
      };
    }.gruvbox;

    cursor = {
      # These are all nice so I'll keep them here for later.

      vanilla = {
        package = pkgs.vanilla-dmz;
        name = "DMZ-Black";
        size = 24;
      };

      breeze = {
        package = pkgs.kdePackages.breeze;
        name = "breeze_cursors";
        size = 24;
      };

      simp1e = {
        package = pkgs.simp1e-cursors;
        name = "Simp1e-Gruvbox-Dark";
        size = 24;
      };

      capitaine = {
        package = pkgs.capitaine-cursors-themed;
        name = "Capitaine Cursors (Gruvbox)";
        size = 24;
      };

      phinger = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors-dark";
        size = 24;
      };
    }.simp1e;

    opacity.terminal = 0.8;
  };
}
