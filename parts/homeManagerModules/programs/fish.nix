{ config, lib, ... }:

let
  cfg = config.programs.fish;
in {
  options.programs.fish.theme = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
  };

  config.programs.fish.interactiveShellInit = lib.optionalString (cfg.theme != null) ''
    fish_config theme choose ${lib.escapeShellArg cfg.theme}
  '';
}
