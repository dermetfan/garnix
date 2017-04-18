{ natExternalInterface }:

{
  networking.nat = {
    enable = true;
    internalInterfaces = [
      "ve-+" # nixos-containers
    ];
    externalInterface = natExternalInterface;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}
