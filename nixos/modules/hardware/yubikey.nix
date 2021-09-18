{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.yubikey;
in {
  options.hardware.yubikey.enable = lib.mkEnableOption "yubikey";

  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    security.pam.yubico = {
      enable = true;
      mode = "challenge-response";
    };
  };
}
