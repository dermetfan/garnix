{ config, lib, pkgs, ... }:

let
  cfg = config.programs.fish;
in {
  options.programs.fish.theme = with lib; mkOption {
    type = types.str;
    default = "";
  };

  config.programs.fish.interactiveShellInit = lib.mkIf (cfg.theme != "") (
    let
      pkg =
        lib.traceIf (lib.versionOlder "3.3.1" cfg.package.version) ''
          `programs.fish.package` has a recent enough version.
          You can use its `src` attribute directly to access themes
          instead of pulling it from GitHub in the fish theme module.
        ''(
          # TODO use `pkgs.fish.src` directly once above v3.3.1
          pkgs.fetchFromGitHub {
            owner = "fish-shell";
            repo = "fish-shell";
            rev = "e0bc944d5c580fc39e9a3f159ef80caa3823dc16";
            hash = "sha256-PsXAqTGQLuNS48zeCFcWMN9ZdgK3w9lsm+paH7Uip+M=";
          }
        );

      theme = lib.fileContents "${pkg}/share/tools/web_config/themes/${cfg.theme}.theme";

      lines = builtins.filter
        (line: builtins.match "[[:space:]]*|[[:space:]]*#.*" line == null)
        (lib.splitString "\n" theme);

      commands = map (line: "set -U " + line) lines;
    in lib.concatStringsSep "\n" commands + "\n"
  );
}
