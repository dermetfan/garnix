{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.hardening;
in {
  options.profiles.hardening = {
    enable = lib.mkEnableOption "hardening";

    breakHibernation = lib.mkEnableOption "options that break hibernation";
  };

  config = lib.mkIf cfg.enable {
    # Dirty Frag
    # https://discourse.nixos.org/t/is-nixos-affected-by-dirty-frag/77479/2?u=dermetfan
    boot = {
      blacklistedKernelModules = [
        "esp4"
        "esp6"
        "rxrpc"
      ];

      extraModprobeConfig = ''
        install esp4 ${pkgs.coreutils}/bin/false
        install esp6 ${pkgs.coreutils}/bin/false
        install rxrpc ${pkgs.coreutils}/bin/false
      '';
    };

    security = {
      protectKernelImage = lib.mkIf cfg.breakHibernation true;

      sudo.execWheelOnly = true;
    };

    nix.settings.allowed-users = [ "@${config.users.groups.wheel.name}" ];
  };
}
