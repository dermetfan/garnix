{ config, pkgs, ... }:

let
  systemConfig = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [
      (import <nixos-config> {
        inherit pkgs;
        inherit (pkgs) system lib;
        config = systemConfig.config;
      })
    ];
  }).config;

  profile = let
    name = import ./home/profile.nix;

    profiles = rec {
      netbook.home.packages = if config.xsession.enable then with pkgs; [
        audacious
        chromium
        filezilla
        geany
        gpa
        gparted
        keymon
        lilyterm
        nixui
        qalculate-gtk
        rss-glx
        smplayer
        xfce.thunar
        vivaldi
        xarchiver
        xfce.xfconf
        xfe
        xpdf
        zathura
      ] else [];

      notebook.home.packages = if config.xsession.enable then with pkgs; netbook.home.packages ++ [
        android-studio
        audacity
        cool-old-term
        gimp
        jetbrains.idea-community
        kdenlive
        lmms
        meld
        minecraft
        teamspeak_client
        tiled
        torbrowser
        visualvm
      ] else [];
    };
  in profiles.${name};
in {
  home = {
    packages = with pkgs; profile.home.packages ++ [
      pkgs."2048-in-terminal"
      abcde
      bashmount
      binutils
      bundix
      fdupes
      feh
      fortune
      ftop
      fzy
      gnupg
      gptfdisk
      hdparm
      htop
      jq
      lrzip
      mplayer
      mpv
      ncdu
      nethogs
      nox
      openjdk
      parted
      pass
      peco
      ponysay
      progress
      psmisc
      pv
      mercurial
      qemu
      rustracer
      rustracerd
      ranger
      rogue
      rsync
      screenfetch
      sl
      smartmontools
      sshfsFuse
      libsysfs
      unrar
      unzip
      vlc
      wakelan
      wget
      zip
    ] ++ (if config.services.xscreensaver.enable then with pkgs; [
      xscreensaver
    ] else []) ++ (if config.xsession.enable then with pkgs; [
      # X
      arandr
      libnotify
      xorg.xrandr
      xorg.xkill
      xclip
      xsel

      # i3
      i3-gaps
      i3status
      rofi

      # autostart
      parcellite
      tdesktop
      hipchat
      nitrogen
      skype
      volumeicon
    ] else []);

    keyboard = {
      variant = "norman";
      options = [
        "compose:lwin"
        "compose:rwin"
        "eurosign:e"
      ];
    };

    sessionVariableSetter = "pam";
    sessionVariables = {
      SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    };

    file = [
      (import ./home/antigen.nix)
      (import ./home/cargo.nix)
      (import ./home/minecraft.nix)
      (import ./home/hg.nix)
      (import ./home/xpdf.nix)
      (import ./home/xscreensaver.nix)
      (import ./home/zsh.nix)
      (import ./home/i3.nix)
      (import ./home/i3status.nix)
      (import ./home/rofi.nix)
      (import ./home/nitrogen.nix)
      (import ./home/lilyterm.nix)
      (import ./home/dunst.nix)
      (import ./home/volumeicon.nix)
      (import ./home/parcellite.nix)
      (import ./home/htop.nix)
      (import ./home/xfe.nix)
      (import ./home/user-dirs.nix)
    ] ++ (pkgs.callPackage ./home/geany.nix {})
    ++ (pkgs.callPackage ./home/nano.nix {});
  };

  xsession = {
    enable = systemConfig.services.xserver.enable;
    windowManager = "${pkgs.i3-gaps}/bin/i3";
    initExtra = let
      xhost = "${pkgs.xorg.xhost}/bin/xhost";
      xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      xflux = "${pkgs.xflux}/bin/xflux";
      compton = "${pkgs.compton}/bin/compton";
      devmon = "${pkgs.udevil}/bin/devmon";
    in ''
      ${xhost} local:root # allow root to connect to X server for key bindings
      ${xmodmap} -e "keycode 66 = Caps_Lock"
      ${xflux} -l 51.165691 -g 10.45152000000058
      xset r rate 225 27
      xset m 2
      ${compton} -bfD 2
      ${devmon} &
      syndaemon -d -i 0.625 -K -R || :

      ~/.fehbg || nitrogen --restore
      volumeicon &
      parcellite &
      telegram-desktop &
      hipchat &
      skype &
    '';
  };

  programs = {
    git = {
      enable = true;
      userName = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";
      aliases = {
        st = "status -s";
        lg = "lg = log --graph --branches --decorate --abbrev-commit --pretty=medium";
        co = "checkout";
        ci = "commit";
        spull = ''!git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive'';
        extraConfig = ''
          [status]
          submoduleSummary = true

          [diff]
          submodule = log
        '';
      };
    };

    firefox = {
      enable = config.xsession.enable;
      enableAdobeFlash = true;
    };
  };

  services = {
    dunst.enable = config.xsession.enable;
    network-manager-applet.enable = config.xsession.enable;
    xscreensaver.enable = config.xsession.enable;
  };

  gtk = {
    enable = config.xsession.enable;
    themeName = "Vertex-Dark";
    iconThemeName = "Numix";
  };
}
