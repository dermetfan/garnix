{ ... }:

{
  imports = [
    ./common.nix
    ../modules/hotkeys.nix
    ../modules/lid.nix
    ../modules/touchpad.nix
    ../modules/graphical.nix
  ];

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
}
