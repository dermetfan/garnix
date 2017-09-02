{ config, lib, pkgs, ... }:

let
  cfg = config.config.hotkeys;

  keyCodes = {
    Shift_L = 42;
    Shift_R = 54;
    PrtScr = 99;
  };

  packages = with pkgs; [
    light
    maim
    slop # required by `maim -s`
    xorg.xhost
    xorg.xinput
    xorg.xrandr
  ];
in {
  options.config.hotkeys = with lib; {
    enable = mkEnableOption "hotkeys";

    keyCodes = mkOption {
      type = with types; submodule {
        options = {
          # https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h
          XF86ScreenSaver = mkOption {
            type = listOf int;
            default = [ 112 ];
          };
          XF86MonBrightnessUp = mkOption {
            type = listOf int;
            default = [ 225 ];
          };
          XF86MonBrightnessDown = mkOption {
            type = listOf int;
            default = [ 224 ];
          };
          XF86TouchpadToggle = mkOption {
            type = listOf int;
            default = [ 191 ];
          };
          XF86Suspend = mkOption {
            type = listOf int;
            default = [ 142 ];
          };
          XF86Hibernate = mkOption {
            type = listOf int;
            default = [];
            description = "If empty, <literal>XF86Suspend</literal> with right or left Shift is used.";
          };
          XF86Display = mkOption {
            type = listOf int;
            default = [ 25 125 ];
          };
        };
      };
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      actkbd = {
        enable = true;
        bindings = with keyCodes // cfg.keyCodes;
          [
            {
              keys = XF86MonBrightnessUp;
              events = [ "key" "rep" ];
              command = "light -A 10";
            }
            {
              keys = XF86MonBrightnessDown;
              events = [ "key" "rep" ];
              command = "light -U 10";
            }
            {
              keys = [ Shift_L ] ++ XF86MonBrightnessUp;
              events = [ "key" "rep" ];
              command = "light -rA 1";
            }
            {
              keys = [ Shift_R ] ++ XF86MonBrightnessUp;
              events = [ "key" "rep" ];
              command = "light -rA 1";
            }
            {
              keys = [ Shift_L ] ++ XF86MonBrightnessDown;
              events = [ "key" "rep" ];
              command = "light -rU 1";
            }
            {
              keys = [ Shift_R ] ++ XF86MonBrightnessDown;
              events = [ "key" "rep" ];
              command = "light -rU 1";
            }
            {
              keys = XF86TouchpadToggle;
              # since we use xinput instead of synclient, make sure to authorize root for your X server
              # use `xauth add` to authorize root or copy an authorized user's ~/.Xauthority to /root or run `xhost local:root`
              command = let
                # apparently resolves wrong package, xf86-input-synaptics-1.8.3-dev, in which bin/synclient doesn't exist
                # synclient = "${pkgs.xorg.xf86inputsynaptics}/bin/synclient";
                touchpad = "SynPS/2 Synaptics TouchPad";
              in
                # synclient seems to have no effect while syndaemon is running (also doesn't disable mouse keys)
                # "${synclient} TouchpadOff=$(${synclient} | grep -c 'TouchpadOff[[:space:]]*=[[:space:]]*0')";
                "export DISPLAY=':0.0' && xinput --set-prop '${touchpad}' 'Device Enabled' $(xinput --list-props '${touchpad}' | grep -c 'Device Enabled (138):[[:space:]].*0')";
            }
            {
              keys = XF86Suspend;
              command = "systemctl suspend";
            }
            {
              keys = XF86ScreenSaver;
              command = let
                xscreensaver-command = "${pkgs.xscreensaver}/bin/xscreensaver-command";
                script = pkgs.writeScript "XF86ScreenSaver.sh" ''
                  #! ${pkgs.bash}/bin/bash
                  if [[ `who | wc -l` > 1 ]]; then
                      systemctl start physlock
                  else
                      ${xscreensaver-command} -lock
                  fi
                '';
              in "${script}";
            }
            {
              keys = [ PrtScr ];
              command = "mkdir -pm 777 /tmp/screenshots && maim /tmp/screenshots/`date --iso-8601=ns`.png";
            }
            {
              keys = [ Shift_L PrtScr ];
              command = "mkdir -pm 777 /tmp/screenshots && maim -slc .5,.5,.5,.25 /tmp/screenshots/`date --iso-8601=ns`.png";
            }
            {
              keys = [ Shift_R PrtScr ];
              command = "mkdir -pm 777 /tmp/screenshots && maim -sluc .5,.5,.5,.25 /tmp/screenshots/`date --iso-8601=ns`.png";
            }
            {
              keys = XF86Display;
              command = let
                script = pkgs.writeScript "XF86Display.sh" ''
                  #! ${pkgs.bash}/bin/bash
                  export DISPLAY=:0.0
                  outputs="`xrandr | grep -Eo '^.*[[:space:]]+connected' | cut -d ' ' -f 1`"
                  for output in $outputs; do
                    xrandr --output $output --auto
                  done
                '';
              in "${script}";
            }
          ] ++
          (if builtins.length XF86Hibernate == 0 then [
            {
              keys = [ Shift_L ] ++ XF86Suspend;
              command = "systemctl hibernate";
            }
            {
              keys = [ Shift_R ] ++ XF86Suspend;
              command = "systemctl hibernate";
            }
          ] else [
            {
              keys = XF86Hibernate;
              command = "systemctl hibernate";
            }
          ]);
        };

      physlock = {
        enable = true;
        disableSysRq = true;
      };

      xserver.displayManager.sessionCommands = ''
        xhost local:root # allow root to connect to X server for hotkeys
      '';
    };

    systemd.services."actkbd@".path = packages;

    environment.systemPackages = packages;
  };
}
