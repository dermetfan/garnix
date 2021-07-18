{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.bat;
in {
  options.config.programs.bat.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.bat.enable;
    defaultText = "<option>config.programs.bat.enable</option>";
    description = "Whether to configure bat.";
  };

  config.programs.bat = lib.mkIf cfg.enable {
    config.theme = "Monokai Extended Origin";
  };
}

