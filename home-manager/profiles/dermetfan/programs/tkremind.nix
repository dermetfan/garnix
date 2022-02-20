{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.tkremind;
in {
  options.profiles.dermetfan.programs.tkremind.enable = lib.mkEnableOption "tkremind" // {
    default = config.programs.tkremind.enable or false;
  };

  config.programs = {
    tkremind = {
      colorscheme = "gruvbox-light";
      extraArgs = "-m -b1";
      extraConfig = ''
        AutoClose 1
        ShowTodaysReminders 0
      '' + lib.optionalString (config.home.sessionVariables ? EDITOR) ''
        Editor {alacritty -e ${config.home.sessionVariables.EDITOR} +%d %s}
      '';
    };

    alacritty.enable = true;
    geany.enable = true;
  };
}
