{ config, lib, utils, pkgs, ... }:

let
  sysCfg = config.passthru.systemConfig or {};
in {
  imports = import home/module-list.nix ++ [
    <nixpkgs/nixos/modules/misc/extra-arguments.nix>
    <nixpkgs/nixos/modules/misc/passthru.nix>
  ];

  config = {
    profiles.desktop.enable = lib.mkDefault config.xsession.enable;

    home = {
      stateVersion = "18.09";

      packages = with pkgs;
        [ less ] ++
        lib.optionals config.xsession.enable [
          arandr
          libnotify
          xorg.xrandr
          xorg.xkill
          xclip
          xsel
        ];

      keyboard = {
        variant = "norman";
        options = [
          "compose:lwin"
          "compose:rwin"
          "eurosign:e"
        ];
      };

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "micro";
        PAGER = "less";
        SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      };
    };

    xsession = {
      enable = sysCfg.services.xserver.enable or false;
      initExtra = lib.optionalString (config.home.keyboard.variant == "norman") ''
        # norman remaps these but we want to keep them
        xmodmap -e "keycode 66 = Caps_Lock"
        xmodmap -e "keycode 133 = Super_L"
        xmodmap -e "keycode 134 = Super_R"
        # norman had the compose key on Super_R
        xmodmap -e "keycode 105 = Multi_key" # Control_R
      '';
    };

    qt = {
      enable = config.xsession.enable;
      useGtkTheme = true;
    };

    services = {
      syncthing.enable = true;
      unclutter.enable = config.xsession.enable && !sysCfg.services.unclutter.enable;
    };

    programs = {
      home-manager.enable = true;

      ranger.enable = true;
      htop  .enable = true;
      micro .enable = true;
      nano  .enable = true;
      tmux  .enable = true;
      zsh   .enable = true;
    };

    systemd.user.startServices = true;

    xdg = {
      enable = true;
      configFile."user-dirs.dirs".text = ''
        XDG_DESKTOP_DIR="/home/dermetfan"
        XDG_DOWNLOAD_DIR="/home/dermetfan/downloads"
        XDG_TEMPLATES_DIR="/home/dermetfan"
        XDG_PUBLICSHARE_DIR="/home/dermetfan"
        XDG_DOCUMENTS_DIR="/data/dermetfan/documents"
        XDG_MUSIC_DIR="/data/dermetfan/audio/music"
        XDG_PICTURES_DIR="/data/dermetfan/images"
        XDG_VIDEOS_DIR="/data/dermetfan/videos"
      '';
    };
  };
}
