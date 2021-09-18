{ self, config, pkgs, lib, ... }:

{
  nix = {
    binaryCachePublicKeys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];

    trustedUsers = [
      "root"
      "@${config.users.groups.wheel.name}"
    ];
  };

  boot = {
    loader.timeout = 1;

    supportedFilesystems = [ "zfs" ];

    zfs = {
      forceImportAll  = false;
      forceImportRoot = false;
    };
  };

  networking.hostId = lib.mkDefault (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));

  environment.systemPackages = with pkgs;
    [ ntfs3g exfat ] ++
    lib.optional config.programs.zsh.enable nix-zsh-completions;

  programs = {
    bash.enableCompletion = lib.versionAtLeast "1.11.5" lib.version; # breaks impure nix-shell, see https://github.com/NixOS/nix/issues/976
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
    };

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
}
