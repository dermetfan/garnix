{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.rofi;
in {
  options.profiles.dermetfan.programs.rofi.enable = lib.mkEnableOption "rofi" // {
    default = config.programs.rofi.enable;
  };

  config.programs = {
    foot.enable = true;

    rofi = {
      plugins = with pkgs; [
        rofi-calc
      ];

      terminal = if config.programs.foot.server.enable then "footclient" else "foot";

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
}
