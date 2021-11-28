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
        plugins = with pkgs; [
          rofi-calc
        ];

        terminal = "alacritty";

        theme = let
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          "@import" = "gruvbox-dark-soft";
          window.width = mkLiteral "40%";
          mainbox.children = map mkLiteral [ "inputbar" "message" "listview" "mode-switcher" ];
          element-icon.margin = mkLiteral "0 6px 0 0";
        };

        extraConfig = {
          modi = lib.concatStringsSep "," (with pkgs; [
            "power:${rofi-power-menu}/bin/rofi-power-menu"
            "calc"
            "emoji:${rofimoji}/bin/rofimoji"
            "drun"
            "run"
            "ssh"
          ]);
          show-icons = true;
        };
      };
    };
  };
}
