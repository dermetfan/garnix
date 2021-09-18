{ nixosConfig, config, lib, pkgs, ... }:

{
  imports = import ./module-list.nix;

  config = {
    fonts.fontconfig.enable = true;

    home = {
      username = nixosConfig.users.users.dermetfan.name;
      homeDirectory = nixosConfig.users.users.dermetfan.home;

      keyboard = {
        layout = "us,ru";
        variant = "norman,phonetic";
      };

      packages = with pkgs; [ less ];

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "kak";
        PAGER = "less";
        LESS = "-RiW -#.05 -n4 -z-3";
      };
    };

    programs = {
      home-manager.enable = true;

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

    systemd.user.startServices = true;

    xdg.enable = true;
  };
}
