{ nixosConfig, config, lib, ... }:

let
  cfg = config.users.diemetfan;
in {
  options.users.diemetfan = lib.mkEnableOption "diemetfan" // {
    default = nixosConfig.users.users ? diemetfan;
  };

  config = lib.mkIf cfg {
    home = lib.optionalAttrs (nixosConfig.users.users ? diemetfan) {
      username = nixosConfig.users.users.diemetfan.name;
      homeDirectory = nixosConfig.users.users.diemetfan.home;
    } // {
      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "geany";
        PAGER = "less";
        LESS = "-RiW -#.05 -n4 -z-3";
      };
    };

    programs = {
      alacritty.enable = true;
      ranger.enable = true;
      broot.enable = true;
      htop.enable = true;
      geany.enable = true;
      kakoune.enable = true;
      tmux.enable = true;
      fish.enable = true;
    };
  };
}
