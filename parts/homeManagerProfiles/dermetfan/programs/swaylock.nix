{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.swaylock;
in {
  options.profiles.dermetfan.programs.swaylock.enable = lib.mkEnableOption "swaylock" // {
    default = config.programs.swaylock.enable or false;
    description = ''
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
  };

  config = lib.mkIf (cfg.enable && config.programs.swaylock.package.pname == "swaylock-effects") {
    programs.swaylock.settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-caps-lock = true;
      show-keyboard-layout = true;
      effect-blur = "7x5";
      fade-in = 0.2;
      datestr = "%a, %Y-%m-%d";
    };
  };
}
