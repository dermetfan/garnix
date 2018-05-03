{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.office;
in {
  options.profiles.office.enable = lib.mkEnableOption "office programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; lib.optionals config.xsession.enable [
      libreoffice
    ];
  };
}
