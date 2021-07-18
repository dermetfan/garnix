{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.volumeicon;
in {
  options       .programs.volumeicon.enable = lib.mkEnableOption "volumeicon";
  options.config.programs.volumeicon.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.volumeicon.enable;
    defaultText = "<option>programs.volumeicon.enable</option>";
    description = "Whether to configure volumeicon.";
  };

  config = lib.mkMerge [
    { home.packages = lib.optional config.programs.volumeicon.enable pkgs.volumeicon; }

    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        alacritty
        alsaUtils
      ];

      xdg.configFile."volumeicon/volumeicon".text = ''
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
    })
  ];
}
