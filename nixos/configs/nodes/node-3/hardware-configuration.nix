{ self, config, ... }:

{
  imports = [
    self.inputs.nixpkgs.nixosModules.notDetected
    ./network.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "ehci_pci" "ahci" "sd_mod"
      "r8169" # the network interface driver for networking in the initial ramdisk
    ];
    kernelModules = [ "kvm-intel" ];
    loader.systemd-boot.enable = true;

    kernelNetwork = {
      enable = true;
      ipv4 = builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0;
    };
  };

  fileSystems = {
    "${config.boot.loader.efi.efiSysMountPoint}" = {
      device = "/dev/disk/by-uuid/8155-EE58";
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
    { device = "/dev/disk/by-uuid/403c1b7b-9697-48e4-ae07-cd49353cf231"; }
  ];
}
