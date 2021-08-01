{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaylock;
in {
  options.programs.swaylock = with lib; {
    enable = mkEnableOption "swaylock";
    package = mkOption {
      type = types.package;
      default = pkgs.swaylock;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = builtins.trace ''
      swaylock requires /etc/pam.d/swaylock to be installed.
      Without it you will not be able to unlock: https://github.com/swaywm/sway/issues/3631
      Add this to your system configuration if required:

      security.pam.services.swaylock.text = builtins.readFile "''${pkgs.swaylock}/etc/pam.d/swaylock";

      or

      security.pam.services.swaylock = {};
    '' [ cfg.package ];

    xdg.configFile = lib.mkIf (cfg.package.name == "swaylock-effects-${cfg.package.version}") {
      "swaylock/config".text = ''
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
  };
}
