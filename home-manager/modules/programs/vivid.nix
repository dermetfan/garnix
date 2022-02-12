{ config, lib, pkgs, ... }:

let
  cfg = config.programs.vivid;
in {
  options.programs.vivid = with lib; {
    enable = mkEnableOption "set LS_COLORS";
    theme = mkOption {
      type = types.str;
      default = "gruvbox-dark";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.LS_COLORS = lib.fileContents (
      pkgs.runCommand "vivid-LS_COLORS" {
        # XXX switch back to release channel once it has a recent enough version of vivid
        buildInputs = [ (builtins.getFlake "github:NixOS/nixpkgs/1882c6b7368fd284ad01b0a5b5601ef136321292").legacyPackages.${pkgs.system}.vivid ];
      } ''
        vivid generate ${lib.escapeShellArg cfg.theme} > $out
      ''
    );
  };
}
