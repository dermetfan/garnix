{ config, pkgs, lib }:

lib.mkMerge [
  (import ./common.nix {
    inherit config pkgs lib;
  })

  (import ../modules/hotkeys.nix {
    inherit config pkgs;
  })

  (import ../modules/lid.nix)

  (import ../modules/touchpad.nix {
    inherit config;
  })

  (import ../modules/graphical.nix {
    inherit pkgs lib;
  })

  {
    passthru.settings.touchpad = {
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
]
