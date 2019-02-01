{ config, lib, ... }:

let
  cfg = config.config.profiles.notebook;
in {
  options.config.profiles.notebook.enable = lib.mkEnableOption "notebook settings";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
    };
  };
}
