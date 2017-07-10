{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; lib.optionals config.xsession.enable [
    libreoffice
  ];
}
