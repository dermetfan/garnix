{ config, lib, ... }:

{
  programs.browserpass = {
    enable = lib.mkDefault (
      config.programs.firefox.enable ||
      config.programs.chromium.enable
    );
    browsers = [
      "vivaldi"
      "chromium"
      "firefox"
    ];
  };
}
