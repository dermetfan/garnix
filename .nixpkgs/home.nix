{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      pkgs."2048-in-terminal"
      abcde
      android-studio
      arandr
      audacious
      audacity
      bashmount
      bundix
      chromium
      cool-old-term
      fdupes
      feh
      filezilla
      fortune
      ftop
      fzy
      geany
      gimp
      git
      gnupg
      gpa
      gparted
      gptfdisk
      hdparm
      hipchat
      htop
      i3status
      idea.idea-community
      jq
#      kdenlive
      keymon
      lilyterm
      lmms
      lrzip
      meld
      minecraft
      mplayer
      mpv
      ncdu
      nethogs
      nixui
      nox
      openjdk
      parcellite
      parted
      pass
      peco
      ponysay
      progress
      psmisc
      pv
      mercurial
      networkmanagerapplet
      nitrogen
      qalculate-gtk
      qemu
      rustracer
      rustracerd
      ranger
      rofi
      rogue
      rss-glx
      rsync
      screenfetch
      skype
      sl
      smartmontools
      smplayer
      sshfsFuse
      libsysfs
      tdesktop
      teamspeak_client
      xfce.thunar
      tiled
      tor
      unrar
      unzip
      visualvm
      vivaldi
      vlc
      volumeicon
      wakelan
      wget
      xarchiver
      xfce.xfconf
      xfe
      xpdf
      zathura
      zip
    ];

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
  };

  programs.firefox = {
    enable = true;
    enableAdobeFlash = true;
  };

  services = {
    xscreensaver.enable = true;
    network-manager-applet.enable = true;
    dunst.enable = true;
    udiskie.enable = true;
  };

  gtk = {
    enable = true;
    themeName = "Vertex-Dark";
    iconThemeName = "Numix";
  };
}
