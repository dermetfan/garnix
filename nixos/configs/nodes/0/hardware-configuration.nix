{ self, config, ... }:

{
  imports = [ self.inputs.nixpkgs.nixosModules.notDetected ];

  networking = {
    hostId = "e064db73";

    interfaces.enp30s0 = {
      macAddress = "d8:d3:85:d7:ea:69";
      useDHCP = true;
    };
  };

  nix = {
    maxJobs = 4;
    buildMachine.speedFactor = 2;
  };

  boot = {
    initrd.availableKernelModules = [ "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];

    loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/ata-SAMSUNG_SP2504C_S09QJ1GLB66805";
      zfsSupport = true;
    };

    tmpOnTmpfs = true;

    zfs.extraPools = [ "tank" ];
  };

  fileSystems = {
    "/" = {
      device = "root";
      fsType = "zfs";
    };

    "${config.misc.data.mountPoint}" = {
      device = "root/data";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/61081a38-841b-40d7-9ce2-4b97f39472fc"; }
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
}
