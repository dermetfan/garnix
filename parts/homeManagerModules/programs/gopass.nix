{ config, lib, pkgs, ... }:

let
  cfg = config.programs.gopass;

  format = pkgs.formats.gitIni {};
in {
  options.programs.gopass = {
    enable = lib.mkEnableOption "gopass";

    package = lib.mkPackageOption pkgs "gopass" {};

    settings = lib.mkOption {
      inherit (format) type;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton cfg.package;

    xdg.configFile."gopass/config".source = format.generate "config" cfg.settings;
  };
}
