{ config, lib, ... }:

let
  cfg = config.programs.alacritty;
in {
  options.programs.alacritty.sensible = lib.mkEnableOption "sensible defaults" // {
    default = true;
  };

  config = lib.mkIf cfg.sensible {
    programs.alacritty.settings = lib.optionalAttrs (config.home.sessionVariables ? "SHELL") {
      shell.program = config.home.sessionVariables.SHELL;
    };
  };
}
