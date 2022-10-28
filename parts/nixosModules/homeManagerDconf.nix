_:

{ config, lib, ... }:

let
  cfg = config.home-manager.nixos.enableDconfIfNeeded;
in {
  key = toString ./homeManagerDconf.nix;

  options.home-manager.nixos.enableDconfIfNeeded = lib.mkEnableOption "enable dconf in NixOS configuration if needed by home-manager configuration" // { default = true; };

  config.programs.dconf.enable = lib.mkIf (
    cfg &&
    builtins.any (k: let
      v = config.home-manager.users.${k};
    in
      v.dconf.settings != {} ||
      v.services.easyeffects.enable ||
      v.services.pulseeffects.enable
    ) (builtins.attrNames config.home-manager.users)
  ) true;
}
