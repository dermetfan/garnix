{ config, pkgs, ... }:

{
  xsession.initExtra = "compton -b";

  home.packages = [ pkgs.compton ];
}
