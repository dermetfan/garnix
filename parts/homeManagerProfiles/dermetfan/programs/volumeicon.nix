{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.volumeicon;
in {
  options.profiles.dermetfan.programs.volumeicon.enable = lib.mkEnableOption "volumeicon" // {
    default = config.programs.volumeicon.enable or false;
  };

  config = {
    home.packages = with pkgs; [
      alacritty
      alsa-utils
    ];

    programs.volumeicon.settings = ''
      [Alsa]
      card=default

      [Notification]
      show_notification=true
      notification_type=0

      [StatusIcon]
      stepsize=2
      onclick=alacritty -e alsamixer
      theme=Blue Bar
      use_panel_specific_icons=false
      lmb_slider=false
      mmb_mute=false
      use_horizontal_slider=false
      show_sound_level=true
      use_transparent_background=false

      [Hotkeys]
      up_enabled=true
      down_enabled=true
      mute_enabled=true
      up=XF86AudioRaiseVolume
      down=XF86AudioLowerVolume
      mute=XF86AudioMute
    '';
  };
}
