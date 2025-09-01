{ nixosConfig ? null, config, lib, ... }:

{
  stylix = {
    # XXX currently broken, breaks the build even when not using KDE
    targets.kde.enable = false;

    # Seems this was forgotten in this file:
    # https://github.com/nix-community/stylix/blob/release-25.05/stylix/home-manager-integration.nix
    # TODO fix upstream?
    icons = nixosConfig.stylix.icons or {};
  };

  home.pointerCursor = lib.mkIf (config.stylix.cursor != null) {
    enable = lib.mkDefault true;

    gtk.enable = lib.mkDefault true;

    x11 = lib.mkIf (nixosConfig.services.xserver.enable or false || config.xsession.enable) {
      enable = lib.mkDefault true;
    };

    sway = lib.mkIf (!config.home.pointerCursor.x11.enable) {
      enable = lib.mkDefault true;
    };

    hyprcursor = lib.mkIf config.wayland.windowManager.hyprland.enable {
      enable = lib.mkDefault true;
    };
  };
}
