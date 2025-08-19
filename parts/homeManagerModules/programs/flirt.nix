{ config, lib, pkgs, ... }:

let
  cfg = config.programs.flirt;

  tomlFormat = pkgs.formats.toml {};
in {
  options.programs.flirt = {
    enable = lib.mkEnableOption "flirt";

    bindings = lib.mkOption {
      type = lib.types.nullOr tomlFormat.type;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.flirt ];

    xdg.configFile."flirt/bindings.toml" = lib.mkIf (cfg.bindings != null) {
      source = tomlFormat.generate "bindings.toml" cfg.bindings;
    };
  };
}
