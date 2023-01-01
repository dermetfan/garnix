{ config, lib, pkgs, ... }:

lib.mkIf config.programs.micro.enable {
  home.packages = [ pkgs.mkinfo ];
}
