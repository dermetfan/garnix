{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.rofi;
in {
  options.config.programs.rofi.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.rofi.enable;
    defaultText = "<option>programs.rofi.enable</option>";
    description = "Whether to configure rofi.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      alacritty.enable = true;

      rofi = {
        borderWidth = 0;
        separator = "none";
        width = 25;
        terminal = "alacritty";
        extraConfig = {
          scrollbar-width = 5;
          opacity = 25;
          theme = "${pkgs.rofi}/share/rofi/themes/Monokai";
        };
      };
    };
  };
}
