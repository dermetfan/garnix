{ nixosConfig, config, lib, ... }:

let
  cfg = config.users.dermetfan;
in {
  options.users.dermetfan = lib.mkEnableOption "dermetfan" // {
    default = nixosConfig.users.users ? dermetfan;
  };

  config = lib.mkIf cfg {
    home = {
      username = nixosConfig.users.users.dermetfan.name;
      homeDirectory = nixosConfig.users.users.dermetfan.home;

      keyboard = {
        layout = "us,ru";
        variant = "norman,phonetic";
      };

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "kak";
        PAGER = "less";
        LESS = "-RiW -#.05 -n4 -z-3";
      };
    };

    programs = {
      alacritty.enable = true;
      ranger.enable = true;
      broot.enable = true;
      htop.enable = true;
      micro.enable = true;
      kakoune.enable = true;
      nano.enable = true;
      tmux.enable = true;
      fish.enable = true;

      browserpass = {
        enable = lib.mkDefault (
          config.programs.firefox.enable ||
          config.programs.chromium.enable
        );
        browsers = [
          "vivaldi"
          "chromium"
          "firefox"
        ];
      };
    };
  };
}
