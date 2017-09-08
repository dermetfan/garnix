{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.rofi;
in {
  options.config.programs.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        rofi
        st
      ];

      file.".config/rofi/config".text = ''
        rofi.bw: 0
        rofi.separator-style: none
        rofi.scrollbar-width: 5
        rofi.width: 25
        rofi.opacity: 25
        rofi.fake-transparency: true
        rofi.fake-background: screenshot
        rofi.terminal: st
        ! rofi.ssh-client: mosh
        #include "${pkgs.rofi}/share/rofi/themes/Monokai.theme"
      '';
    };
  };
}
