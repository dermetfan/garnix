{ options, config, lib, ... }:

{
  config = lib.optionalAttrs (options ? stylix) {
    home.pointerCursor = lib.mkIf (config.stylix.cursor != null) {
      enable = lib.mkDefault true;

      hyprcursor = lib.mkIf config.wayland.windowManager.hyprland.enable {
        enable = lib.mkDefault true;
      };
    };
  };
}
