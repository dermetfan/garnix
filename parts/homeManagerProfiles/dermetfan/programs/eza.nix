{ lib, pkgs, ... }:

{
  programs.eza = {
    enableAliases = false;

    icons = true;
    git = true;

    extraOptions = [
      "--long"
      "--group"
      "--time-style=iso"
      "--group-directories-first"
    ];
  };

  # for icons
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
}
