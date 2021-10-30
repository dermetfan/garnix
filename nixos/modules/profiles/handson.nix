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
        layout = "us";
        xkbVariant = "norman";
        xkbOptions = "compose:lwin,compose:rwin,eurosign:e";

        synaptics.twoFingerScroll = true;
      };

      kmscon = {
        extraConfig = ''
          xkb-layout=us
          xkb-variant=norman
          xkb-options=compose:lwin,compose:rwin,eurosign:e
        '';
        hwRender = true;
      };

      logind.lidSwitch = "ignore";
    };

    hardware = {
      opengl.enable = true;
      bluetooth.powerOnBoot = false;
      uhk.enable = true;
    };
  };
}
