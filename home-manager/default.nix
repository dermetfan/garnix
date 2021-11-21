{ pkgs, ... }:

{
  imports = import ./module-list.nix;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [ less ];

  programs.home-manager.enable = true;

  systemd.user.startServices = true;

  xdg.enable = true;
}
