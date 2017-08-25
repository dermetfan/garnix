{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    openjdk
    gradle
  ] ++ lib.optionals config.xsession.enable [
    android-studio
    jetbrains.idea-community
    visualvm
  ];
}
