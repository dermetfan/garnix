{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.ripgrep;
in {
  options.profiles.dermetfan.programs.ripgrep.enable = lib.mkEnableOption "ripgrep" // {
    default = config.programs.ripgrep.enable or false;
  };

  config.programs.ripgrep.settings = ''
    --smart-case
  '';
}
