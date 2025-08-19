{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.flirt;
in {
  options.profiles.dermetfan.programs.flirt = {
    enable = lib.mkEnableOption "flirt" // {
      default = config.programs.flirt.enable;
    };

    remapMovement = lib.mkEnableOption ''
      a keymap that uses JKIL instead of HJKL,
      but for the Norman keyboard layout,
      so it is NIRO
    '' // {
      default = true;
    };
  };

  config.programs.flirt.bindings = let
    dir = if cfg.remapMovement then {
      left = "n";
      down = "i";
      up = "r";
      right = "o";
    } else {
      left = "h";
      down = "j";
      up = "k";
      right = "l";
    };
  in lib.mkIf cfg.enable {
    ${dir.down}     = "next";
    "<down>"        = "next";
    ${dir.up}       = "prev";
    "<up>"          = "prev";
    "S-${dir.down}" = "move-next";
    "S-<down>"      = "move-next";
    "S-${dir.up}"   = "move-prev";
    "S-<up>"        = "move-prev";
    "q"             = "quit";
    "S-q"           = "abort";
    ${dir.left}     = "go-to-parent";
    "<ret>"         = "enter-dir";
    ${dir.right}    = "enter-dir";
    "<spc>"         = "toggle-select";
    "<tab>"         = "cycle";
    "."             = "hide-show";
    "/"             = "filter";
  };
}
