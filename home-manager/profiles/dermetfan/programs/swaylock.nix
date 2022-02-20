{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.swaylock;
in {
  options.profiles.dermetfan.programs.swaylock.enable = lib.mkEnableOption "swaylock" // {
    default = config.programs.swaylock.enable or false;
  };

  config = lib.mkIf (cfg.enable && config.programs.swaylock.package.pname == "swaylock-effects") {
    xdg.configFile."swaylock/config".text = ''
      screenshots
      clock
      indicator
      indicator-caps-lock
      show-keyboard-layout
      effect-blur=7x5
      fade-in=0.2
      datestr=%a, %Y-%m-%d
    '';
  };
}
