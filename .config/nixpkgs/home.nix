{ config, lib, utils, pkgs, ... }:

let
  sysCfg = config.passthru.systemConfig or {};
in {
  imports = import home/module-list.nix ++ [
    <nixpkgs/nixos/modules/misc/extra-arguments.nix>
    <nixpkgs/nixos/modules/misc/passthru.nix>
  ];

  config = {
    config = {
      profiles.desktop.enable = config.xsession.enable;

      programs = {
        ranger.enable = true;
        htop  .enable = true;
        micro .enable = true;
        nano  .enable = true;
        tmux  .enable = true;
      };
    };

    home = {
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

      sessionVariableSetter =
        if with utils; toShellPath sysCfg.users.users.dermetfan.shell or null == toShellPath pkgs.zsh
        then "zsh"
        else "pam";
      sessionVariables = {
        EDITOR = "micro";
        PAGER = "less";
        SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      };
    };

    xsession.enable = sysCfg.services.xserver.enable or false;

    programs = {
      home-manager = {
        enable = true;
        path = "${pkgs.home-manager-src}";
      };

      zsh.enable = true;
    };
  };
}
