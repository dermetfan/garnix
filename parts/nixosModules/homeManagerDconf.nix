_:

{ config, lib, ... }:

let
  cfg = config.home-manager.nixos.enableDconfIfNeeded;
in {
  key = toString ./homeManagerDconf.nix;

  options.home-manager.nixos.enableDconfIfNeeded = lib.mkEnableOption "enable dconf in NixOS configuration if needed by home-manager configuration" // { default = true; };

  config.programs.dconf.enable = lib.mkIf (
    cfg &&
    builtins.any (user:
      user.dconf.settings != {} ||
      user.services.easyeffects.enable ||
      user.services.pulseeffects.enable
    ) (builtins.attrValues config.home-manager.users)
  ) true;
}
