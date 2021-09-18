{ config, lib, ... }:

let
  cfg = config.profiles.netbook;
in {
  options.profiles.netbook.enable = lib.mkEnableOption "netbook settings";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    zramSwap = {
      enable = true;
      memoryPercent = 75;
      numDevices = 2;
    };
  };
}
