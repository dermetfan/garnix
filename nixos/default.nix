{ config, pkgs, lib, ... }:

{
  imports = [
    ./data.nix
    ./dev.nix
    ./hotkeys.nix
    ./uhk.nix
    ./dns-watch.nix
    ./1.1.1.1.nix
    ./steam-controller.nix

    profiles/netbook.nix
    profiles/notebook.nix
    profiles/machines/MSI_PE60-6QE.nix
  ];

  config = {
    config.hotkeys.enable = true;

    nix.binaryCachePublicKeys = [
      (builtins.readFile ../keys/cache.pub)
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];

    boot = {
      loader.timeout = 1;

      supportedFilesystems = [ "zfs" ];

      zfs = {
        forceImportAll  = false;
        forceImportRoot = false;
      };
    };

    time.timeZone = "Europe/Berlin";

    environment = {
      systemPackages = with pkgs;
        [ ntfs3g exfat ] ++
        lib.optional (config.hardware.pulseaudio.enable && config.services.xserver.enable) pavucontrol ++
        lib.optional config.programs.zsh.enable nix-zsh-completions;

      variables = lib.mkIf config.services.xserver.enable {
        SDL_VIDEO_X11_DGAMOUSE = "0"; # fix for jumping mouse (in qemu)
        _JAVA_AWT_WM_NONREPARENTING = "1"; # fix for some blank java windows
      };

      noXlibs = !config.services.xserver.enable;
    };

    programs = {
      bash.enableCompletion = builtins.compareVersions builtins.nixVersion "1.11.5" > 0; # breaks impure nix-shell, see https://github.com/NixOS/nix/issues/976
      zsh = {
        enable = true;
        enableCompletion = lib.mkDefault false;
        shellAliases = {
          l = "ls -lah";
          ll = "ls -lh";
        };
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

    console.useXkbConfig = true;

    services = {
      openssh.enable = true;

      dbus.packages = lib.optional config.hardware.bluetooth.enable pkgs.blueman;

      xserver = {
        layout = "us";
        xkbVariant = "norman";
        xkbOptions = "compose:lwin,compose:rwin,eurosign:e";

        synaptics = {
          twoFingerScroll = true;
          palmDetect      = true;
        };
      } // (if lib.versionOlder "19.09" lib.version then {} else {
        displayManager.slim.defaultUser = lib.mkDefault config.users.users.dermetfan.name;
      });

      kmscon = {
        extraConfig = ''
          xkb-layout=us
          xkb-variant=norman
          xkb-options=compose:lwin,compose:rwin,eurosign:e
        '';
        hwRender = true;
      };

      logind.lidSwitch = "ignore";

      unclutter.enable = config.services.xserver.enable;

      znapzend.enable = builtins.any (x: x == "zfs") (map (fs: fs.fsType) (builtins.attrValues config.fileSystems));
    };

    sound.mediaKeys = {
      # Does not work with hardware.pulseaudio.enable
      # because amixer cannot connect to PulseAudio
      # user daemon as another user (root)
      # => share PulseAudio cookie?
      enable = !config.services.xserver.enable;
      volumeStep = "2%";
    };

    hardware.bluetooth.powerOnBoot = false;

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;

      users = {
        root.hashedPassword = "$6$9876543210987654$TOIH9KzZb/Tfa/0F2mobm4Hl2vwh5bFp8As6VFCaqSIu5KoqgdpESOmuMI04J8DUPGdvEjDMkWi9Lxqhu5gZ50";

        dermetfan = {
          description = "dermetfan.net";
          isNormalUser = true;
          hashedPassword = "$6$0123456789012345$h8FEllCQBQYziYvFVOhIqGRvt/z3lPO5wU.07Uz9Y/E2AvSUtq9ITQZTivMFN0gSSpFrDJ0P32k9t5uG4c47D0";
          extraGroups = with lib;
            optional config.security.sudo                 .enable "wheel"          ++
            optional config.networking.networkmanager     .enable "networkmanager" ++
            optional config.virtualisation.docker         .enable "docker"         ++
            optional config.virtualisation.virtualbox.host.enable "vboxusers"      ++
            optional config.programs.adb                  .enable "adbusers";
        };
      };
    };
  };
}
