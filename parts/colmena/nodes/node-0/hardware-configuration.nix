{ inputs, ... }:

{ config, ... }:

{
  imports = [ inputs.nixpkgs.nixosModules.notDetected ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ehci_pci" "ata_piix" "usbhid" "sd_mod"
        "tg3" # the network interface driver for networking in the initial ramdisk
      ];

      network = {
        udhcpc.enable = true;
        flushBeforeStage2 = false;
      };
    };

    kernelModules = [ "kvm-intel" ];

    loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/ata-SAMSUNG_SP2504C_S09QJ1GLB66805";
    };
  };

  networking.interfaces.enp30s0 = {
    macAddress = "d8:d3:85:d7:ea:69";
    wakeOnLan.enable = true;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/FACE-4EBA";
      fsType = "vfat";
    };

    "/" = {
      device = "root/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "root/nix";
      fsType = "zfs";

      options = [
        "noatime"
        "nodiratime"
      ];
    };

    "/home" = {
      device = "root/home";
      fsType = "zfs";
    };

    "/state" = {
      device = "root/state";
      fsType = "zfs";
      neededForBoot = true; # for impermanence
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6640895e-8392-4d3f-b3c2-5f3ee1097d83"; }
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
}
