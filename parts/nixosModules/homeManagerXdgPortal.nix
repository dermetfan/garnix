_:

{ config, lib, ... }:

let
  cfg = config.home-manager.nixos.linkXdgPortalPathsIfNeeded;
in {
  key = toString ./homeManagerXdgPortal.nix;

  options.home-manager.nixos.linkXdgPortalPathsIfNeeded = lib.mkEnableOption "link XDG portal paths in NixOS configuration if needed by home-manager configuration" // { default = true; };

  config.environment.pathsToLink = lib.optionals (
    cfg &&
    config.home-manager.useUserPackages &&
    builtins.any (user: user.xdg.portal.enable) (builtins.attrValues config.home-manager.users)
  ) [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
