{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.starship;
in {
  options.config.programs.starship.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.starship.enable;
    defaultText = "<option>programs.starship.enable</option>";
    description = "Whether to configure starship.";
  };

  config = {
    home.packages =
      [ pkgs.powerline-fonts ] ++
      lib.optional config.programs.starship.enable pkgs.starship;

    programs.starship.settings = {
      add_newline = false;
      line_break.disabled = true;
      cmd_duration.disabled = true;
    };
  };
}
