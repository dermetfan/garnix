{ config, pkgs, ... }:

rec {
  imports = [
    ./common.nix
    ./lib/data.nix
    ./lib/steam-controller.nix
  ] ++ (if services.xserver.enable then [
    ./lib/gtk.nix
  ] else []);

  nixpkgs.config.allowUnfree = true;

  boot.loader.timeout = 1;

  environment.systemPackages = with pkgs; if config.services.xserver.enable then [
    xflux
  ] else [];

  networking = {
    hostName = "dermetfan";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 8080 ];
    nat = {
      enable = true;
      internalInterfaces = [
        "ve-+" # nixos-containers
      ];
      externalInterface = "enp3s0";
    };
  };

  programs.light.enable = true;

  services = {
    printing.enable = true;

    kmscon = {
      extraConfig = ''
        xkb-layout=us
        xkb-variant=norman
        xkb-options=compose:lwin,compose:rwin,eurosign:e
      '';
      hwRender = true;
    };

    wakeonlan.interfaces = [ {
      interface = "enp3s0";
    } ];

    logind.extraConfig = ''
      HandleLidSwitch=ignore
    '';

    xserver = {
      enable = true;

      displayManager.sessionCommands = let
        xhost = "${pkgs.xorg.xhost}/bin/xhost";
        xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      in ''
        ${xhost} local:root # allow root to connect to X server for key bindings
        ${xmodmap} -e "keycode 66 = Caps_Lock"
        xset r rate 225 27
        xset m 2
        compton -bfD 2
        devmon &
        xflux -l 51.165691 -g 10.45152000000058
        xscreensaver -no-splash &
        syndaemon -d -i 0.625 -K -R
      '';

      displayManager.slim.defaultUser = "dermetfan";
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
      desktopManager.xterm.enable = false;

      synaptics = {
        enable = true;
        twoFingerScroll = true;
        palmDetect = true;
        minSpeed = "0.825";
        maxSpeed = "2";
      };
    };

    actkbd = {
      enable = true;
      bindings = let
        light = "${pkgs.light}/bin/light";
        maim = "${pkgs.maim}/bin/maim";
      in [
        # https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h
        { # XF86MonBrightnessUp
          keys = [ 225 ];
          events = [ "key" "rep" ];
          command = "${light} -A 10";
        }
        { # XF86MonBrightnessDown
          keys = [ 224 ];
          events = [ "key" "rep" ];
          command = "${light} -U 10";
        }
        { # Shift_L + XF86MonBrightnessUp
          keys = [ 42 225 ];
          events = [ "key" "rep" ];
          command = "${light} -rA 1";
        }
        { # Shift_R + XF86MonBrightnessUp
          keys = [ 54 225 ];
          events = [ "key" "rep" ];
          command = "${light} -rA 1";
        }
        { # Shift_L + XF86MonBrightnessDown
          keys = [ 42 224 ];
          events = [ "key" "rep" ];
          command = "${light} -rU 1";
        }
        { # Shift_R + XF86MonBrightnessDown
          keys = [ 54 224 ];
          events = [ "key" "rep" ];
          command = "${light} -rU 1";
        }
        { # XF86TouchpadToggle
          keys = [ 191 ];
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
        { # XF86Suspend
          keys = [ 142 ];
          command = "systemctl suspend";
        }
        { # Shift_L + XF86Suspend (XF86Hibernate)
          keys = [ 42 142 ];
          command = "systemctl hibernate";
        }
        { # Shift_R + XF86Suspend (XF86Hibernate)
          keys = [ 54 142 ];
          command = "systemctl hibernate";
        }
        { # XF86ScreenSaver / P1
          keys = [ 112 ];
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
        { # PrtScr
          keys = [ 99 ];
          command = "${maim} /tmp/screenshot\\ `date --iso-8601=ns`.png";
        }
        { # Shift_L + PrtScr
          keys = [ 42 99 ];
          command = "PATH=$PATH:${pkgs.slop}/bin && ${maim} -s -c 1,0,0,0.75 /tmp/screenshot\\ `date --iso-8601=ns`.png";
        }
        { # Shift_R + PrtScr
          keys = [ 54 99 ];
          command = "PATH=$PATH:${pkgs.slop}/bin && ${maim} -s -c 1,0,0,0.75 /tmp/screenshot\\ `date --iso-8601=ns`.png";
        }
        { # XF86Display
          keys = [ 25 125 ];
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
      ];
    };
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      hack-font
      ucs-fonts
      libertine
      nerdfonts
      proggyfonts
      terminus_font
      anonymousPro
      font-awesome-ttf
      fira
      fira-code
      fira-mono
    ];
  };

  hardware.pulseaudio.enable = false; # does not work with sound.mediaKeys.enable because amixer cannot connect to PulseAudio user daemon as another user (root) => share PulseAudio cookie?

  virtualisation.docker.enable = true;
}
