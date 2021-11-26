{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaylock;
in {
  options.programs.swaylock = with lib; {
    enable = mkEnableOption ''
      swaylock.

      swaylock requires <filename>/etc/pam.d/swaylock</filename> to be installed.
      Without it you will not be able to unlock:
      <link xlink:href="https://github.com/swaywm/sway/issues/3631">Sway issue 3631</link>

      Add this to your system configuration if required:

      <code>
      security.pam.services.swaylock.text =
        builtins.readFile "''${pkgs.swaylock}/etc/pam.d/swaylock";
      </code>

      This might also be sufficient:

      <code>
      security.pam.services.swaylock = {};
      </code>
    '';

    package = mkOption {
      type = types.package;
      default = pkgs.swaylock;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

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
