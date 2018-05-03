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
    home.packages = with pkgs; [
      rofi-unwrapped
      alacritty
    ];

    programs.rofi = {
      borderWidth = 0;
      separator = "none";
      width = 25;
      terminal = "alacritty";
      extraConfig = ''
        rofi.scrollbar-width: 5
        rofi.opacity: 25
        rofi.theme: ${pkgs.rofi-unwrapped}/share/rofi/themes/Monokai
      '';
      # TODO rofi-pass
    };
  };
}
