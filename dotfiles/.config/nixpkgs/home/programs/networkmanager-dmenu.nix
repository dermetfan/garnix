{ config, lib, pkgs, ... }:

let
  cfg = config.programs.networkmanager-dmenu;
in with lib; {
  options.programs.networkmanager-dmenu = {
    enable = mkEnableOption "networkmanager_dmenu";

    config = mkOption {
      type = types.attrs;
      default = {
        dmenu = {
          rofi_highlight = true;
          wifi_chars = "▂▄▆█";
        } // (if config.programs.rofi.enable then {
          dmenu_command = "rofi";
        } else {});
        dmenu_passphrase.rofi_obscure = false;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.networkmanager_dmenu ];
    xdg.configFile."networkmanager-dmenu/config.ini".text = generators.toINI {} cfg.config;
  };
}
