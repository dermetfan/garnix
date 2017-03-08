{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
#      2048-in-terminal
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
      tdesktop
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
      ANDROID_HOME = "${pkgs.androidsdk_extras}/libexec";
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "Robin Stumm";
      userEmail = "serverkorken@gmail.com";
      aliases = {
        st = "status -s";
        lg = "log --graph --branches --decorate --abbrev-commit --pretty=medium";
        ci = "commit";
        co = "checkout";
        spull = "!git pull \"$@\" && git submodule sync --recursive && git submodule update --init --recursive"; # https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407#.jepjuse2y
      };
      extraConfig = ''
        [status]
        submoduleSummary = true

        [diff]
        submodule = log
      '';
    };

    firefox = {
      enable = true;
      enableAdobeFlash = true;
    };
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
