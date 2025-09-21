{ config, lib, pkgs, ... }:

let
  cfg = config.programs.vivid;
in {
  options.programs.vivid = with lib; {
    enable = mkEnableOption "set LS_COLORS";

    theme = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.LS_COLORS = lib.fileContents (
      pkgs.runCommand "vivid-LS_COLORS" {
        buildInputs = with pkgs; [ vivid ];
      } ''
        vivid generate ${lib.escapeShellArg cfg.theme} > $out
      ''
    );
  };
}
