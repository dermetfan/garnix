{ config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.environments.office.enable.default = false;

  config.home.packages = with pkgs;
    [ liberation_ttf_v2 ] ++
    lib.optionals config.profiles.dermetfan.environments.gui.enable [
      gnucash
      libreoffice
    ];
}
