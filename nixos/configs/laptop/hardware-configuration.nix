{ self, config, lib, pkgs, ... }:

{
  imports = [ self.inputs.nixpkgs.nixosModules.notDetected ];

  hardware."MSI PE60-6QE" = {
    enable = true;
    enableGPU = false;
  };

  boot.loader.grub = {
    efiSupport = true;
    zfsSupport = true;
    device = "nodev";
    configurationLimit = 15;
    efiInstallAsRemovable = true;
  };

  fileSystems = {
    "/" = {
      device = "root";
      fsType = "zfs";

      options = [
        "noatime"
        "nodiratime"
      ];
    };

    "${config.misc.data.mountPoint}" = {
      device = "root/data";
      fsType = "zfs";

      options = [
        "noatime"
        "nodiratime"
      ];
    };

    "${config.boot.loader.efi.efiSysMountPoint}" = {
      device = "/dev/disk/by-uuid/D3B9-5EEA";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/dfea6847-f57b-4700-93eb-8e18f650f37b"; }
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
