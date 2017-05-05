{
  target = ".config/volumeicon/volumeicon";
  text = ''
    [Alsa]
    card=default

    [Notification]
    show_notification=true
    notification_type=0

    [StatusIcon]
    stepsize=2
    onclick=xterm -e 'alsamixer'
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
}
