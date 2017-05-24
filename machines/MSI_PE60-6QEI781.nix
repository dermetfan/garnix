{ config, lib, pkgs, ... }:

let
  bumblebee = pkgs.writeScript "bumblebee.sh" ''
    ${pkgs.bumblebee}/bin/bumblebeed -Dg ${config.users.groups.wheel.name}
  '';
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

    kernelModules = [
      "kvm-intel"
      "bbswitch"
    ];

    blacklistedKernelModules = [
      "nouveau" # causes CPU stalls with intel GPU driver
    ];

    extraModulePackages = with pkgs.linuxPackages; [
      bbswitch
    ];

    tmpOnTmpfs = true;
  };

  nix.maxJobs = lib.mkDefault 8;

  hardware = {
    enableAllFirmware = true;
    # nvidiaOptimus.disable = true;
    bumblebee = {
      # enable = true;
      driver = "nvidia";
    };
    opengl.driSupport32Bit = true;
    bluetooth.enable = true;
    pulseaudio = {
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  security.sudo.extraConfig = ''
    %${config.users.groups.wheel.name} ALL=(ALL:ALL) NOPASSWD:${bumblebee}
  '';

  services.xserver = {
    displayManager.sessionCommands = ''
      sudo ${bumblebee}
    '';

    videoDrivers = [ "intel" ];
  };
}
