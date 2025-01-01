_:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.gui;
in {
  options.profiles.gui.enable = lib.mkEnableOption "gui settings";

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs;
        lib.optional config.hardware.pulseaudio.enable pavucontrol;

      variables = {
        SDL_VIDEO_X11_DGAMOUSE = "0"; # fix for jumping mouse (in qemu)
        _JAVA_AWT_WM_NONREPARENTING = "1"; # https://github.com/xmonad/xmonad/issues/126#issue-248175415
      };
    };

    services = {
      blueman.enable = config.hardware.bluetooth.enable;

      unclutter.enable = config.services.xserver.enable;
    };

    hardware.graphics.enable = true;
  };
}
