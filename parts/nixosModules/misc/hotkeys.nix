_:

{ config, lib, pkgs, ... }:

let
  cfg = config.misc.hotkeys;

  keyCodes = {
    Shift_L = 42;
    Shift_R = 54;
    PrtScr  = 99;
  };

  packages = with pkgs;
    (lib.optional cfg.sound.enable alsa-utils) ++
    (lib.optionals config.services.xserver.enable [
      maim slop
      xorg.xhost
      xorg.xinput
      xorg.xrandr
      xscreensaver
    ]);
in {
  options.misc.hotkeys = with lib; {
    enable = mkEnableOption "hotkeys";

    screenshotsDirectory = mkOption {
      type = types.path;
      default = "/tmp/screenshots";
    };

    sound = {
      enable = mkEnableOption "sound keys" // {
        default = true;
      };

      volumeStep = mkOption {
        type = types.str;
        default = "2%";
        example = "1";
        description = ''
          The value by which to increment/decrement volume on media keys.
          See amixer(1) for allowed values.
        '';
      };
    };

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
          XF86Battery = mkOption {
            type = listOf int;
            default = [];
          };
          XF86_AudioMute = mkOption {
            type = listOf int;
            default = [ 113 ];
          };
          XF86_AudioLowerVolume = mkOption {
            type = listOf int;
            default = [ 114 ];
          };
          XF86_AudioRaiseVolume = mkOption {
            type = listOf int;
            default = [ 115 ];
          };
          XF86XK_AudioMicMute = mkOption {
            type = listOf int;
            default = [ 190 ];
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
              keys = XF86Suspend;
              command = "systemctl suspend";
            }
            {
              keys = XF86ScreenSaver;
              command = let
                script = pkgs.writeScript "XF86ScreenSaver.sh" ''
                  #! ${pkgs.bash}/bin/bash
                  num_logins=`who | wc -l`
                  ${lib.optionalString config.services.xserver.enable ''
                    if [[ $num_logins = 1 && `systemctl is-active display-manager` ]]; then
                        ${pkgs.xscreensaver}/bin/xscreensaver-command -lock && exit
                    fi
                  ''}
                  if [[ $num_logins > 1 ]]; then
                    systemctl start physlock
                  fi
                '';
              in "${script}";
            }
          ] ++
          (if XF86Hibernate == [] then [
            {
              keys = [ Shift_L ] ++ XF86Suspend;
              command = "systemctl hibernate";
            }
            {
              keys = [ Shift_R ] ++ XF86Suspend;
              command = "systemctl hibernate";
            }
          ] else [ {
            keys = XF86Hibernate;
            command = "systemctl hibernate";
          } ]) ++
          (lib.optional (XF86Battery != [] && config.services.tlp.enable) {
            keys = XF86Battery;
            command = lib.getExe (pkgs.writeShellApplication {
              name = "XF86Battery.sh";
              text = ''
                mode=$(tlp-stat --mode)
                if [[ "$mode" = battery* ]]; then
                  sudo ${lib.getExe config.services.tlp.package} ac
                else
                  sudo ${lib.getExe config.services.tlp.package} bat
                fi
              '';
            });
          }) ++
          (lib.optionals config.services.xserver.enable [
            {
              keys = XF86Display;
              command = let
                script = pkgs.writeScript "XF86Display.sh" ''
                  #! ${pkgs.bash}/bin/bash
                  export DISPLAY=:0
                  outputs="`xrandr | grep -Eo '^.*[[:space:]]+connected' | cut -d ' ' -f 1`"
                  for output in $outputs; do
                    xrandr --output $output --auto
                  done
                '';
              in "${script}";
            }
            {
              keys = [ PrtScr ];
              command = "mkdir -pm 777 ${cfg.screenshotsDirectory} && maim ${cfg.screenshotsDirectory}/`date --iso-8601=ns`.png";
            }
            {
              keys = [ Shift_L PrtScr ];
              command = "mkdir -pm 777 ${cfg.screenshotsDirectory} && maim -slc .5,.5,.5,.25 ${cfg.screenshotsDirectory}/`date --iso-8601=ns`.png";
            }
            {
              keys = [ Shift_R PrtScr ];
              command = "mkdir -pm 777 ${cfg.screenshotsDirectory} && maim -sluc .5,.5,.5,.25 ${cfg.screenshotsDirectory}/`date --iso-8601=ns`.png";
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
                "export DISPLAY=':0' && xinput --set-prop '${touchpad}' 'Device Enabled' $(xinput --list-props '${touchpad}' | grep -c 'Device Enabled ([[:digit:]]\\+):[[:space:]].*0')";
            }
          ]) ++
          (lib.optionals cfg.sound.enable [
            {
              keys = XF86_AudioMute;
              events = [ "key" ];
              command = "amixer -q set Master toggle";
            }

            {
              keys = XF86_AudioLowerVolume;
              events = [ "key" "rep" ];
              command = "amixer -q set Master ${cfg.sound.volumeStep}- unmute";
            }

            {
              keys = XF86_AudioRaiseVolume;
              events = [ "key" "rep" ];
              command = "amixer -q set Master ${cfg.sound.volumeStep}+ unmute";
            }

            {
              keys = XF86XK_AudioMicMute;
              events = [ "key" ];
              command = "amixer -q set Capture toggle";
            }
          ]);
        };

      physlock = {
        enable = true;
        disableSysRq = true;
        lockOn = {
          suspend   = false;
          hibernate = false;
        };
      };

      xserver.displayManager.sessionCommands = ''
        xhost local:root # allow root to connect to X server for hotkeys
      '';
    };

    systemd.services."actkbd@".path = packages;

    environment.systemPackages = packages;
  };
}
