{ inputs, ... }:

{ lib, ... }:

{
  imports = [ inputs.nixpkgs.nixosModules.notDetected ];

  hardware.bluetooth.enable = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    loader.grub = {
      efiSupport = true;
      zfsSupport = true;
      device = "nodev";
      configurationLimit = 15;
      efiInstallAsRemovable = true;
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

  powerManagement.cpuFreqGovernor = "powersave";
}
