{ config, lib, ... }:

{
  programs.vivid = {
    enable = true;
  } // lib.optionalAttrs (!(config.stylix.targets.vivid.enable or false)) {
    activeTheme = "gruvbox-dark";
  };
}
