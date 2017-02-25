{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    tmpOnTmpfs = true;

    supportedFilesystems = [ "zfs" ];

    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  time.timeZone = "Europe/Berlin";

  environment = {
    systemPackages = with pkgs; [
      nix-zsh-completions
      bashmount
      file
      tree
      lsof
      ntfs3g
      udevil
      ftop
    ] ++ (if config.services.xserver.enable then [
      xorg.xrandr
      xorg.xkill
      xscreensaver
      xclip
      xsel
      libnotify
    ] else []);

    variables = if config.services.xserver.enable then {
      SDL_VIDEO_X11_DGAMOUSE = "0"; # fix for jumping mouse (in qemu)
      _JAVA_AWT_WM_NONREPARENTING = "1"; # fix for some blank java windows
    } else {};
  };

  programs = {
    # bash.enableCompletion = true; # breaks impure nix-shell, see https://github.com/NixOS/nix/issues/976
    zsh = {
      enable = true;
      shellAliases = {
        l = "ls -lah";
        ll = "ls -lh";
      };
      interactiveShellInit = pkgs.callPackage ./lib/antigen.nix {};
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

  i18n.consoleUseXkbConfig = true;

  services = {
    openssh.enable = true;

    xserver = {
      layout = "us";
      xkbVariant = "norman";
      xkbOptions = "compose:lwin,compose:rwin,eurosign:e";
    };

    unclutter.enable = true;
  };

  sound.mediaKeys = {
    enable = !config.services.xserver.enable;
    volumeStep = "2%";
  };

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
        ] ++ (if config.virtualisation.docker.enable then [
          "docker"
        ] else []);
      };
    };
  };
}
