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
    ./swaylock.nix
    ./yubikey.nix

    profiles/gui.nix
    profiles/netbook.nix
    profiles/notebook.nix
    profiles/machines/MSI_PE60-6QE.nix

    <home-manager/nixos>
  ];

  config = {
    config.hotkeys.enable = true;

    nix = {
      binaryCachePublicKeys = [
        (builtins.readFile ../keys/cache.pub)
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      ];

      trustedUsers = [
        "root"
        "@${config.users.groups.wheel.name}"
      ];
    };

    nixpkgs = {
      config = import ../nixpkgs/config.nix;
      overlays =
        let overlays = ../nixpkgs/overlays;
        in lib.mapAttrsToList
          (k: v: import "${overlays}/${k}")
          (lib.filterAttrs
            (k: v: (v == "directory" && builtins.pathExists "${overlays}/${k}/default.nix") || lib.strings.hasSuffix ".nix" k)
            (builtins.readDir overlays)
          )
      ;
    };

    boot = {
      loader.timeout = 1;

      supportedFilesystems = [ "zfs" ];

      zfs = {
        forceImportAll  = false;
        forceImportRoot = false;
      };
    };

    time.timeZone = "Europe/Berlin";

    networking.hostId = lib.mkDefault (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));

    environment = {
      systemPackages = with pkgs;
        [ ntfs3g exfat ] ++
        lib.optional config.programs.zsh.enable nix-zsh-completions;

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

      pipewire.alsa.support32Bit = pkgs.stdenv.isx86_64;

      znapzend.enable = builtins.any (x: x == "zfs") (map (fs: fs.fsType) (builtins.attrValues config.fileSystems));
    };

    # Does not work with hardware.pulseaudio.enable
    # because amixer cannot connect to PulseAudio
    # user daemon as another user (root)
    # => share PulseAudio cookie?
    sound.mediaKeys.volumeStep = "2%";

    hardware = {
      opengl = {
        enable = true;
        driSupport32Bit = pkgs.stdenv.isx86_64;
      };

      bluetooth = {
        powerOnBoot = false;

        # https://nixos.wiki/wiki/Bluetooth#Enabling_A2DP_Sink
        settings.General.Enable = lib.concatStringsSep "," ["Source" "Sink" "Media" "Socket"];
      };

      pulseaudio = {
        support32Bit = pkgs.stdenv.isx86_64;
        extraConfig = ''
          load-module module-echo-cancel source_name=noecho
          set-default-source noecho
        '';
      };
    };

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.fish;

      users = {
        root.hashedPassword = "$6$9876543210987654$TOIH9KzZb/Tfa/0F2mobm4Hl2vwh5bFp8As6VFCaqSIu5KoqgdpESOmuMI04J8DUPGdvEjDMkWi9Lxqhu5gZ50";

        dermetfan = {
          description = "dermetfan.net";
          isNormalUser = true;
          hashedPassword = "$6$0123456789012345$h8FEllCQBQYziYvFVOhIqGRvt/z3lPO5wU.07Uz9Y/E2AvSUtq9ITQZTivMFN0gSSpFrDJ0P32k9t5uG4c47D0";
          extraGroups = with lib;
            optional config.security.sudo                 .enable "wheel"          ++
            optional config.programs.light                .enable "video"          ++
            optional config.networking.networkmanager     .enable "networkmanager" ++
            optional config.virtualisation.docker         .enable "docker"         ++
            optional config.virtualisation.virtualbox.host.enable "vboxusers"      ++
            optional config.programs.adb                  .enable "adbusers";
        };
      };
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.dermetfan = lib.mkMerge [
        (import ../home-manager)
        { nixos.enable = true; }
      ];
    };
  };
}
