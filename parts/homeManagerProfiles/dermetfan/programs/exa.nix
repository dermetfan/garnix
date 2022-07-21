{ lib, pkgs, ... }:

let
  aliases.exa = lib.concatStringsSep " " [
    "exa"
    "--long"
    "--group"
    "--time-style=iso"
    "--icons"
    "--git"
    "--group-directories-first"
  ];
in {
  programs = {
    bash.shellAliases = aliases;
    zsh .shellAliases = aliases;
    fish.shellAliases = aliases;
  };

  # for icons
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
}
