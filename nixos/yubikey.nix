{ pkgs, ... }:

{
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
  };
}
