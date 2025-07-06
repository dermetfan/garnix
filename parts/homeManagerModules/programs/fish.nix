{ config, lib, ... }:

let
  cfg = config.programs.fish;
in {
  options.programs.fish.theme = with lib; mkOption {
    type = types.str;
    default = "";
  };

  config.programs.fish.interactiveShellInit = lib.mkIf (cfg.theme != "") (
    let
      theme = lib.fileContents "${cfg.package}/share/fish/tools/web_config/themes/${cfg.theme}.theme";

      lines = builtins.filter
        (line: builtins.match "[[:space:]]*|[[:space:]]*#.*" line == null)
        (lib.splitString "\n" theme);

      commands = map (line: "set -U " + line) lines;
    in lib.concatStringsSep "\n" commands + "\n"
  );
}
