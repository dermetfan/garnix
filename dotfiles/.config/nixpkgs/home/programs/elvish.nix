{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.elvish;
in {
  options       .programs.elvish.enable = lib.mkEnableOption "elvish";
  options.config.programs.elvish = with lib; {
    enable = mkOption {
      type = types.bool;
      default = config.programs.elvish.enable;
      defaultText = "<option>config.programs.elvish.enable</option>";
      description = "Whether to configure Elvish.";
    };

    enableRanger = mkOption {
      type = types.bool;
      default = config.config.programs.ranger.enable;
      defaultText = "<option>config.config.programs.ranger.enable</option>";
      description = "Whether to configure Ranger for Elvish.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional config.programs.elvish.enable pkgs.elvish;

    home.file.".elvish/rc.elv".text = ''
      use readline-binding

      edit:prompt = { styled (tilde-abbr $pwd)'❯ ' green }
      edit:rprompt = (constantly (styled (whoami)@(hostname) green inverse))

      # edit:-matcher['''] = [p]{ edit:match-prefix &smart-case $p }
    '';
  };
}
