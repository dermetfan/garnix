{ config, lib, ... }:

let
  cfg = config.profiles.dermetfan.programs.elvish;
in {
  options.profiles.dermetfan.programs.elvish.enable = lib.mkEnableOption {
    default = config.programs.elvish.enable or false;
  };

  config = {
    programs.zoxide.enable = true;

    home.file.".elvish/rc.elv".text = ''
      use readline-binding

      edit:prompt = { styled (tilde-abbr $pwd)'❯ ' green }
      edit:rprompt = (constantly (styled (whoami)@(hostname) green inverse))

      # edit:-matcher['''] = [p]{ edit:match-prefix &smart-case $p }

      eval (zoxide init elvish | slurp)
    '';
  };
}
