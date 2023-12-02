{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.shells;
in {
  options.profiles.dermetfan.programs.shells.enable = with lib; mkEnableOption "common shells" // {
    default = with config.programs;
      bash.enable || zsh.enable || fish.enable;
    defaultText = ''
      <option>
      with config.programs;
      bash.enable || zsh.enable || fish.enable
      </option>
    '';
  };

  config.programs = let
    aliases = {
      l  = "eza --git-ignore";
      ll = "eza --all";
    };
  in {
    eza.enable = true;
    bash.shellAliases = aliases;
    zsh .shellAliases = aliases;
    fish.shellAliases = aliases;
  };
}

