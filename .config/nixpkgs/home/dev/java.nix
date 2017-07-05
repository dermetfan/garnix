{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    openjdk
  ] ++ (lib.optionals config.xsession.enable [
    android-studio
    jetbrains.idea-community
    visualvm
  ]);
}
