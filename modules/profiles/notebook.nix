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

#      ../modules/lid.nix
#      ../modules/touchpad.nix
#      ../modules/graphical.nix
#      ../modules/dev.nix
    };

    nixpkgs.config.allowUnfree = true;

    networking = {
      hostName = "dermetfan";
      networkmanager.enable = true;
    };

    services = {
      printing.enable = true;

      xserver.synaptics = {
        minSpeed = "0.825";
        maxSpeed = "2";
      };
    };

    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
    };

    hardware.pulseaudio.enable = false; # does not work with sound.mediaKeys.enable because amixer cannot connect to PulseAudio user daemon as another user (root) => share PulseAudio cookie?
  };
}
