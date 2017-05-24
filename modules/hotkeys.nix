{ config, pkgs }:

let
  settings = {
    keys = {
      # https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h
      XF86ScreenSaver = 112;
      XF86MonBrightnessUp = 225;
      XF86MonBrightnessDown = 224;
      XF86TouchpadToggle = 191;
      XF86Suspend = 142;
      XF86Hibernate = null;
      XF86Display = [ 25 125 ];
    };
  } // config.passthru.settings.hotkeys or {};
in {
  services.actkbd = {
    enable = true;
    bindings = let
      light = "${pkgs.light}/bin/light";
      maim = "${pkgs.maim}/bin/maim";
      keys = settings.keys // {
        Shift_L = 42;
        Shift_R = 54;
        PrtScr = 99;
      };
    in with keys; [
      {
        keys = [ XF86MonBrightnessUp ];
        events = [ "key" "rep" ];
        command = "${light} -A 10";
      }
      {
        keys = [ XF86MonBrightnessDown ];
        events = [ "key" "rep" ];
        command = "${light} -U 10";
      }
      {
        keys = [ Shift_L XF86MonBrightnessUp ];
        events = [ "key" "rep" ];
        command = "${light} -rA 1";
      }
      {
        keys = [ Shift_R XF86MonBrightnessUp ];
        events = [ "key" "rep" ];
        command = "${light} -rA 1";
      }
      {
        keys = [ Shift_L XF86MonBrightnessDown ];
        events = [ "key" "rep" ];
        command = "${light} -rU 1";
      }
      {
        keys = [ Shift_R XF86MonBrightnessDown ];
        events = [ "key" "rep" ];
        command = "${light} -rU 1";
      }
      {
        keys = [ XF86TouchpadToggle ];
        # since we use xinput instead of synclient, make sure to authorize root for your X server
        # use `xauth add` to authorize root or copy an authorized user's ~/.Xauthority to /root or run `xhost local:root`
        command = let
          # apparently resolves wrong package, xf86-input-synaptics-1.8.3-dev, in which bin/synclient doesn't exist
          # synclient = "${pkgs.xorg.xf86inputsynaptics}/bin/synclient";
          touchpad = "SynPS/2 Synaptics TouchPad";
          xinput = "${pkgs.xorg.xinput}/bin/xinput";
        in
          # synclient seems to have no effect while syndaemon is running (also doesn't disable mouse keys)
          # "${synclient} TouchpadOff=$(${synclient} | grep -c 'TouchpadOff[[:space:]]*=[[:space:]]*0')";
          "export DISPLAY=':0.0' && ${xinput} --set-prop '${touchpad}' 'Device Enabled' $(${xinput} --list-props '${touchpad}' | grep -c 'Device Enabled (138):[[:space:]].*0')";
      }
      {
        keys = [ XF86Suspend ];
        command = "systemctl suspend";
      }
      {
        keys = [ XF86ScreenSaver ];
        command = let
          physlock = "${pkgs.physlock}/bin/physlock";
          xscreensaver-command = "${pkgs.xscreensaver}/bin/xscreensaver-command";
          script = pkgs.writeText "XF86ScreenSaver.sh" ''
            #!${pkgs.bash}/bin/bash
            if [ -n "`who`" ]
              then ${physlock} -s
              else ${xscreensaver-command} -lock
            fi
          '';
        in ". ${script}";
      }
      {
        keys = [ PrtScr ];
        command = "${maim} /tmp/screenshot\\ `date --iso-8601=ns`.png";
      }
      {
        keys = [ Shift_L PrtScr ];
        command = "PATH=$PATH:${pkgs.slop}/bin && ${maim} -s -c 1,0,0,0.75 /tmp/screenshot\\ `date --iso-8601=ns`.png";
      }
      {
        keys = [ Shift_R PrtScr ];
        command = "PATH=$PATH:${pkgs.slop}/bin && ${maim} -s -c 1,0,0,0.75 /tmp/screenshot\\ `date --iso-8601=ns`.png";
      }
      {
        keys = XF86Display;
        command = let
          xrandr = "${pkgs.xorg.xrandr}/bin/xrandr -d :0.0";
          script = pkgs.writeText "XF86Display.sh" ''
            #!${pkgs.bash}/bin/bash
            outputs="`${xrandr} | grep -Eo '^.*[[:space:]]+connected' | cut -d ' ' -f 1`"
            for output in $outputs; do
              ${xrandr} --output $output --auto
            done
          '';
        in ". ${script}";
      }
    ] ++ (if XF86Hibernate == null then [
      {
        keys = [ Shift_L XF86Suspend ];
        command = "systemctl hibernate";
      }
      {
        keys = [ Shift_R XF86Suspend ];
        command = "systemctl hibernate";
      }
    ] else [
      {
        keys = [ XF86Hibernate ];
        command = "systemctl hibernate";
      }
    ]);
  };
}
