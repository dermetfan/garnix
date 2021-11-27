{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.exa;
in {
  options.config.programs.exa.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.exa.enable;
    defaultText = "<option>config.programs.exa.enable</option>";
    description = "Whether to configure exa.";
  };

  config = let
    aliases.exa = lib.concatStringsSep " " [
      "exa"
      "--long"
      "--group"
      "--time-style=iso"
      "--icons"
      "--git"
      "--group-directories-first"
    ];
  in lib.mkIf cfg.enable {
    programs = {
      bash.shellAliases = aliases;
      zsh.shellAliases = aliases;
      fish.shellAliases = aliases;
    };

    # for icons
    home.packages = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
  };
}

