{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    jq
    mercurial
    nox
    qemu
  ] ++ (lib.optionals config.xsession.enable [
    meld
  ]);
}
