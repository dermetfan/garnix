{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.ripgrep;
in {
  options       .programs.ripgrep.enable = lib.mkEnableOption "ripgrep";
  options.config.programs.ripgrep.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.ripgrep.enable;
    defaultText = "<option>programs.ripgrep.enable</option>";
    description = "Whether to configure ripgrep.";
  };

  config = {
    home = {
      packages = lib.optional config.programs.ripgrep.enable pkgs.ripgrep;

      sessionVariables.RIPGREP_CONFIG_PATH = config.home.homeDirectory + "/" + config.xdg.configFile."ripgrep".target;
    };

    xdg.configFile."ripgrep".text = ''
      --smart-case
    '';
  };
}
