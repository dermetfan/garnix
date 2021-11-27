{ config, lib, ... }:

let
  cfg = config.config.programs.shells;
in {
  options.config.programs.shells.enable = with lib; mkOption {
    type = types.bool;
    default = with config.programs;
      bash.enable || zsh.enable || fish.enable;
    defaultText = ''
      <option>
      with config.programs;
      bash.enable || zsh.enable || fish.enable
      </option>
    '';
    description = "Whether to configure common shells.";
  };

  config.programs = let
    aliases = {
      l  = "exa --git-ignore";
      ll = "exa --all";
    };
  in lib.mkIf cfg.enable {
    exa.enable = true;
    bash.shellAliases = aliases;
    zsh.shellAliases = aliases;
    fish.shellAliases = aliases;
  };
}

