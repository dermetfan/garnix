{ nixosConfig ? null, ... }:

{
  stylix = {
    # XXX currently broken, breaks the build even when not using KDE
    targets.kde.enable = false;

    # Seems this was forgotten in this file:
    # https://github.com/nix-community/stylix/blob/release-25.05/stylix/home-manager-integration.nix
    # TODO fix upstream?
    icons = nixosConfig.stylix.icons or {};
  };
}
