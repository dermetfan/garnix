{ config, pkgs, ... }:

rec {
  imports = [
    ./hardware-configuration.nix
    ./lib/steam-controller.nix
  ] ++ (if services.xserver.enable then [
    ./lib/gtk.nix
  ] else []);

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      timeout = 1;
      systemd-boot.enable = true;
      grub = {
        efiSupport = true;
        zfsSupport = true;
        configurationLimit = 25;
      };
    };

    tmpOnTmpfs = true;

    blacklistedKernelModules = [
      "nouveau" # causes CPU stalls with intel GPU driver
    ];

    supportedFilesystems = [ "zfs" ];

    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  security.pam.mount = {
    enable = true;
    extraVolumes = [
      ''<volume pgrp="users" mountpoint="/data/%(USER)" path="data/%(USER)" fstype="zfs" />''
    ];
  };

  networking = {
    hostName = "dermetfan";
    hostId = "6abe32dc"; # needs to be set for zfs
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

  time.timeZone = "Europe/Berlin";

  i18n.consoleUseXkbConfig = true;

  environment = {
    systemPackages = with pkgs; [
      nix-zsh-completions
      bashmount
      file
      tree
      lsof
      ntfs3g
      udevil
      xflux
      ftop
    ] ++ (if config.services.xserver.enable then [
      xorg.xrandr
      xscreensaver
      xclip
      xsel
      nitrogen
      libnotify
      parcellite
      volumeicon
      networkmanagerapplet
    ] else []);

    variables = {
      SDL_VIDEO_X11_DGAMOUSE = "0"; # fix for jumping mouse (in qemu)
      _JAVA_AWT_WM_NONREPARENTING = "1"; # fix for some blank java windows
    };

    interactiveShellInit = ''
      export PATH="$PATH:/data/`whoami`/bin"
    '';
  };

  programs = {
    light.enable = true;
    # bash.enableCompletion = true; # breaks impure nix-shell, see https://github.com/NixOS/nix/issues/976
    zsh = {
      enable = true;
      shellAliases = {
        l = "ls -lah";
        ll = "ls -lh";
      };
      interactiveShellInit = let
        curl = "${pkgs.curl}/bin/curl";
        install_antigen = pkgs.writeText "install-antigen.zsh" ''
          #!${pkgs.zsh}/bin/zsh

          antigen="$HOME/.antigen/antigen.zsh"
          url="https://cdn.rawgit.com/zsh-users/antigen/v1.3.1/bin/antigen.zsh"
          checksum="a37f5165f41dd1db9d604e8182cc931e3ffce832cf341fce9a35796a5c3dcbb476ed7d6e6e9c8c773905427af77dbe8bdbb18f16e18b63563c6e460e102096f3"

          installed() { return `[ -f $antigen ]` }

          if installed; then
            . $antigen
          else
            echo "$antigen is missing. Installing..." >&2
            ${curl} $url > /tmp/antigen.zsh

            if ! `echo "$checksum /tmp/antigen.zsh" | sha512sum -c --status`; then
              echo "Abort: wrong sha512 checksum!" >&2
              echo "downloaded from: $url" >&2
              echo "Expected sha512: $checksum" >&2
              echo "Actual   sha512: `sha512sum /tmp/antigen.zsh | cut -d ' ' -f 1`" >&2
              rm -f /tmp/antigen.zsh
            else
              mkdir -p `dirname $antigen`
              mv /tmp/antigen.zsh $antigen
              echo "Installed antigen." >&2
            fi

            if ! installed; then
              echo "Failed to install antigen!" >&2
            else
              . $antigen
            fi
          fi
        '';
      in ". ${install_antigen}";
    };
    nano.nanorc = ''
      set tabsize 4
      set tabstospaces
      set autoindent
      set smarthome
      set nowrap
      set smooth
      set nohelp
    '';
    mosh.enable = true;
    tmux.enable = true;
  };

  services = {
    openssh.enable = true;
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
      layout = "us";
      xkbVariant = "norman";
      xkbOptions = "compose:lwin,compose:rwin,eurosign:e";

      displayManager.sessionCommands = let
        xhost = "${pkgs.xorg.xhost}/bin/xhost";
        xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      in ''
        ${xhost} local:root # allow root to connect to X server for key bindings
        ${xmodmap} -e "keycode 66 = Caps_Lock"
        xset r rate 225 27
        xset m 2
        compton -bfD 2
        nitrogen --restore
        ~/.fehbg
        parcellite &
        nm-applet --sm-disable &
        volumeicon &
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

      videoDrivers = [ "intel" ];
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

    unclutter.enable = true;
  };

  sound.mediaKeys = {
    enable = !config.services.xserver.enable;
    volumeStep = "2%";
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

  hardware = {
    enableAllFirmware = true;
    # nvidiaOptimus.disable = true;
    bumblebee = {
      # enable = true;
      driver = "nouveau";
    };
    opengl.driSupport32Bit = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = false; # does not work with sound.mediaKeys.enable because amixer cannot connect to PulseAudio user daemon as another user (root) => share PulseAudio cookie?
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  virtualisation.docker.enable = true;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        isSystemUser = true;
        hashedPassword = "$6$9876543210987654$TOIH9KzZb/Tfa/0F2mobm4Hl2vwh5bFp8As6VFCaqSIu5KoqgdpESOmuMI04J8DUPGdvEjDMkWi9Lxqhu5gZ50";
      };
      dermetfan = {
        isNormalUser = true;
        hashedPassword = "$6$0123456789012345$h8FEllCQBQYziYvFVOhIqGRvt/z3lPO5wU.07Uz9Y/E2AvSUtq9ITQZTivMFN0gSSpFrDJ0P32k9t5uG4c47D0";
        extraGroups = [
          "wheel"
          "docker"
        ];
      };
    };
  };
}
