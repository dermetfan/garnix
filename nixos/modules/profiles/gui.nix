{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.gui;
in {
  options.profiles.gui.enable = with lib; mkOption {
    type = types.bool;
    default = config.services.xserver.enable;
    description = "gui settings";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          lib.optional config.hardware.pulseaudio.enable pavucontrol;

        variables = {
          SDL_VIDEO_X11_DGAMOUSE = "0"; # fix for jumping mouse (in qemu)
          _JAVA_AWT_WM_NONREPARENTING = "1"; # fix for some blank java windows
        };
      };

      services = {
        blueman.enable = config.hardware.bluetooth.enable;

        unclutter.enable = config.services.xserver.enable;
      };
    })

    { sound.mediaKeys.enable = !cfg.enable; }
  ];
}
