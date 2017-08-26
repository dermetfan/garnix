{ config, lib, pkgs, ... }:

let
  cfg = config.config.profiles.notebook;
in {
  options.config.profiles.notebook.enable = lib.mkEnableOption "notebook settings";

  config = lib.mkIf cfg.enable {
    config = {
      dataPool = {
        enable = true;
        userFileSystems = true;
      };
    };

    nixpkgs.config.allowUnfree = true;

    networking = {
      hostName = "dermetfan";
      networkmanager.enable = true;
    };

    services = {
      xserver.synaptics = {
        enable = true;
        minSpeed = "0.825";
        maxSpeed = "2";
      };
    };

    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
    };
  };
}
