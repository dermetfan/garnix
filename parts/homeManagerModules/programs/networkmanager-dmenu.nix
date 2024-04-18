{ config, lib, pkgs, ... }:

let
  cfg = config.programs.networkmanager-dmenu;
in {
  options.programs.networkmanager-dmenu = with lib; {
    enable = mkEnableOption "networkmanager_dmenu";

    settings = mkOption {
      type = types.attrs;
      default = {
        dmenu = {
          rofi_highlight = true;
          wifi_chars = "▂▄▆█";
        } // lib.optionalAttrs config.programs.rofi.enable {
          dmenu_command = "rofi";
        };
        dmenu_passphrase.rofi_obscure = false;
      } // lib.optionalAttrs (config.home.sessionVariables ? TERMINAL) {
        editor.terminal = config.home.sessionVariables.TERMINAL;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      networkmanager_dmenu

      # for connection editor GUI
      networkmanagerapplet
    ];

    xdg.configFile."networkmanager-dmenu/config.ini".text = lib.generators.toINI {} cfg.settings;
  };
}
