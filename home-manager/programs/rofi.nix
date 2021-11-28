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
        terminal = "alacritty";
        theme = "gruvbox-dark-soft";
        extraConfig = {
          borderWidth = 0;
          width = 25;
          separator = "none";
          scrollbar-width = 5;
          opacity = 25;
        };
      };
    };
  };
}
