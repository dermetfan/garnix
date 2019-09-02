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

  config.home = lib.mkIf cfg.enable {
    packages = lib.optional config.programs.timewarrior.enable pkgs.timewarrior;

    file.".timewarrior/timewarrior.cfg" = {
      text = ''
        import ${pkgs.timewarrior}/share/doc/timew/doc/themes/dark.theme
      '';

      # hack to write file instead of linking (needs to be writable)
      onChange = let
        target = config.home.file.".timewarrior/timewarrior.cfg".target;
      in ''
        cat ${target} > ${target}.tmp
        mv ${target}.tmp ${target}
      '';
    };
  };
}
