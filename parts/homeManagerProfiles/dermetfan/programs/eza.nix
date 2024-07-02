{ lib, pkgs, ... }:

{
  programs.eza = {
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
    enableIonIntegration = false;
    enableNushellIntegration = false;

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
