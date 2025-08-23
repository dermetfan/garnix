{ config, lib, pkgs, ... }:

let
  cfg = config.programs.flirt;

  tomlFormat = pkgs.formats.toml {};
in {
  options.programs.flirt = {
    enable = lib.mkEnableOption "flirt";

    package =
      lib.mkPackageOption pkgs "flirt" {}
      // (if lib.versionOlder pkgs.flirt.version "0.4.1" then {
        # Default in nixpkgs is v0.4
        # which does not have the fish integration yet.
        default = pkgs.flirt.overrideAttrs {
          src = pkgs.fetchFromSourcehut {
            owner = "~hadronized";
            repo = "flirt";
            rev = "d6f88589475b7c626107ee4aef8d7d2908585c56";
            hash = "sha256-yC8Z6RayPKnG0uam930qrGwLvVnHZspZRN3xh+pBRQc=";
          };
        };
      } else lib.warn "pkgs.flirt is recent enough for the default in the home-manager module to be removed" {});

    bindings = lib.mkOption {
      type = lib.types.nullOr tomlFormat.type;
      default = null;
    };

    enableFishIntegration = lib.mkEnableOption ''
      fish integration.
      This does not bind a key, it just makes
      the `flirt_widget` function available,
      which you can then bind yourself.
    '';

    enableZshIntegration = lib.mkEnableOption "zsh integration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.flirt ];

    xdg.configFile."flirt/bindings.toml" = lib.mkIf (cfg.bindings != null) {
      source = tomlFormat.generate "bindings.toml" cfg.bindings;
    };

    programs = {
      fish.shellInit = lib.mkIf cfg.enableFishIntegration ''
        source ${cfg.package.src}/shell/fish/flirt_widget.fish
      '';

      zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
        if [[ $options[zle] = on ]]; then
          source ${cfg.package.src}/shell/fish/flirt_widget
        fi
      '';
    };
  };
}
