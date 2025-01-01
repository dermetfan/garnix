{ inputs, ... }:

{ config, lib, ... }:

{
  imports = [ inputs.nixpkgs.nixosModules.notDetected ];

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  boot = {
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        efiSupport = true;
        zfsSupport = true;
        device = "nodev";
        configurationLimit = 15;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0236-8B6F";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/0c949c06-05d1-40c5-9414-e8f6489f6b43"; }
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
