{ config, lib, ... }:

let
  cfg = config.config.profiles.netbook;
in {
  options.config.profiles.netbook.enable = lib.mkEnableOption "netbook settings";

  config = lib.mkIf cfg.enable {
    config = {
#      ../modules/lid.nix
#      ../modules/touchpad.nix
#      ../modules/graphical.nix
    };

    services.xserver.synaptics = {
      minSpeed = "1";
      maxSpeed = "1.75";
    };

    networking = {
      hostName = "dermetfan-netbook";
      networkmanager.enable = true;
    };

    zramSwap = {
      enable = true;
      memoryPercent = 75;
      numDevices = 2;
    };
  };
}
