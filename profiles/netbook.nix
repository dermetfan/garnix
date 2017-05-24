{ hardware ? {}
, config, pkgs, lib }:

lib.mkMerge [
  (import ./common.nix {
    inherit hardware config pkgs lib;
  })

  (import ../modules/hotkeys.nix {
    inherit pkgs;
    keys = hardware.keys or {};
  })

  (import ../modules/lid.nix)

  (import ../modules/touchpad.nix {
    minSpeed = "1";
    maxSpeed = "1.75";
  })

  (import ../modules/graphical.nix {
    inherit pkgs lib;
  })

  {
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
]
