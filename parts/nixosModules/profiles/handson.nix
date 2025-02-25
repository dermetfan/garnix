_:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.handson;
in {
  options.profiles.handson.enable = lib.mkEnableOption "hands-on settings";

  config = lib.mkIf cfg.enable {
    misc.hotkeys.enable = true;

    profiles.gui.enable = lib.mkDefault config.services.xserver.enable;

    sound.mediaKeys.enable = !config.services.xserver.enable;

    environment.systemPackages = with pkgs;
      [ ntfs3g exfat ] ++
      lib.optional config.programs.zsh.enable nix-zsh-completions;

    services = {
      xserver = {
        xkb = {
          layout = "us";
          variant = "norman";
          options = "compose:lwin,compose:rwin,eurosign:e";
        };

        synaptics.twoFingerScroll = true;
      };

      kmscon = {
        extraConfig = ''
          xkb-layout=${config.services.xserver.xkb.layout}
          xkb-variant=${config.services.xserver.xkb.variant}
          xkb-options=${config.services.xserver.xkb.options}
        '';
        hwRender = true;
      };

      logind.lidSwitch = "ignore";

      udev.packages = [ pkgs.qmk-udev-rules ];
    };

    hardware = {
      opengl.enable = true;
      bluetooth.powerOnBoot = false;
      uhk.enable = true;
      vial.enable = true;
    };
  };
}
