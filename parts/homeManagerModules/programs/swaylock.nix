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
      example = "pkgs.swaylock-effects";
    };
  };

  config.home.packages = lib.optional cfg.enable cfg.package;
}
