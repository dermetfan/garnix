{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.rofi;
in {
  options.config.programs.rofi.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.rofi.enable;
    description = "Whether to enable rofi.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.alacritty ];

    programs.rofi = {
      borderWidth = 0;
      separator = "none";
      width = 25;
      terminal = "alacritty";
      extraConfig = ''
        rofi.scrollbar-width: 5
        rofi.opacity: 25
        rofi.fake-transparency: true
        rofi.fake-background: screenshot
        ! rofi.ssh-client: mosh
        #include "${pkgs.rofi}/share/rofi/themes/Monokai.theme"
      '';
    };
  };
}
