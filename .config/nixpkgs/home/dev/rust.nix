{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    rustracer
    rustracerd
  ];
}
