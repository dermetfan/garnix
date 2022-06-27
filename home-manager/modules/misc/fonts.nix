{ config, lib, pkgs, ... }:

let
  cfg = config.fonts.defaultFonts;

  floor = float: lib.toInt (builtins.elemAt (builtins.match ''^([[:digit:]]+)\.?.*$'' (toString float)) 0);
in {
  options.fonts.defaultFonts = with lib; mkOption {
    type = types.submodule (let
      fontModule = with types; submodule ({ config, ... }: {
        options = {
          family = mkOption {
            type = str;
          };
          familyPango = mkOption {
            type = str;
            default = config.family;
          };
          size = mkOption {
            type = anything; # types.float does not exist
          };
          package = mkOption {
            type = package;
          };
        };
      });
    in {
      options = {
        normal = mkOption {
          type = fontModule;
          default = {
            family = "DejaVu Sans";
            size = 12.0;
            package = pkgs.dejavu_fonts;
          };
        };

        mono = mkOption {
          type = fontModule;
          default = {
            family = "FiraCode Nerd Font Mono";
            size = 12.0;
            package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
          };
        };
      };
    });
    default = {};
  };

  config = let
    inherit (lib) mkOptionDefault mkDefault;

    i3-sway = {
      config.fonts = {
        names = mkDefault [ cfg.mono.family ];
        size = mkDefault cfg.mono.size;
      };
    };
  in {
    home.packages = with pkgs; [
      cfg.normal.package
      cfg.mono.package
      fontpreview
    ];

    gtk.font = {
      name = mkDefault cfg.normal.family;
      package = mkDefault cfg.normal.package;
    };

    programs = {
      alacritty.settings.font = {
        normal.family = mkDefault cfg.mono.family;
        size = mkDefault cfg.mono.size;
      };

      mako.font = with cfg.normal; mkDefault "${familyPango} ${toString size}";

      tkremind.font = mkDefault {
        inherit (cfg.normal) family;
        size = floor cfg.normal.size;
      };
    };

    xsession.windowManager.i3 = i3-sway;
    wayland.windowManager.sway = i3-sway;

    programs.swappy.settings = mkOptionDefault {
      Default = mkOptionDefault {
        text_font = mkDefault cfg.normal.family;
        text_size = mkDefault (floor (cfg.normal.size * 1.5));
      };
    };
  };
}
