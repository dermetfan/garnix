{ config, lib, pkgs, ... }:

let
  bumblebeeHack = {
    enable = false;
    bumblebeed = pkgs.writeScript "bumblebeed.sh" ''
      ${pkgs.bumblebee}/bin/bumblebeed -Dg ${config.users.groups.wheel.name}
    '';
  };
in rec {
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "rtsx_usb_sdmmc"
    ];

    kernelModules = [ "kvm-intel" ] ++
      lib.optional bumblebeeHack.enable "bbswitch";

    blacklistedKernelModules = [
      "nouveau" # causes CPU stalls with intel GPU driver
    ];

    extraModulePackages = with pkgs.linuxPackages;
      lib.optional bumblebeeHack.enable bbswitch;

    tmpOnTmpfs = true;
  };

  nix = {
    maxJobs = lib.mkDefault 8;
    buildCores = 8;
  };

  hardware = {
    enableAllFirmware = true;
#    nvidiaOptimus.disable = true;
#    bumblebee.enable = true;
    opengl.driSupport32Bit = true;
    bluetooth.enable = true;
    pulseaudio = {
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  security.sudo.extraConfig = lib.optionalString bumblebeeHack.enable ''
    %${config.users.groups.wheel.name} ALL=(ALL:ALL) NOPASSWD:${bumblebeeHack.bumblebeed}
  '';

  services.xserver = {
    displayManager.sessionCommands = lib.optionalString bumblebeeHack.enable ''
      sudo ${bumblebeeHack.bumblebeed}
    '';

    videoDrivers = [ "intel" ];
  };
}
