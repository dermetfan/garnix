{ config, lib, pkgs, ... }:

let
  cfg = config.programs.timewarrior;
in {
  options       .programs.timewarrior.enable = lib.mkEnableOption "timewarrior";
  options.config.programs.timewarrior.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.timewarrior.enable;
    defaultText = "<option>programs.timewarrior.enable</option>";
    description = "Whether to configure timewarrior.";
  };

  config.home = {
    packages = lib.optional config.programs.timewarrior.enable pkgs.timewarrior;

    file = lib.mkIf cfg.enable {
      ".timewarrior/extensions/totals" = {
        source = "${pkgs.timewarrior}/share/doc/timew/ext/totals.py";
        executable = true;
      };
    };
  };
}
