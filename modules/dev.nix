{ config }:

let
  settings = {
    natExternalInterface = config.passthru.hardware.interfaces.lan or null;
  } // config.passthru.settings.dev or {};
in {
  networking.nat = {
    enable = true;
    internalInterfaces = [
      "ve-+" # nixos-containers
    ];
    externalInterface = settings.natExternalInterface;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}
