{ self, config, ... }:

{
  imports = [
    self.inputs.nixpkgs.nixosModules.notDetected
    ./network.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci" "ehci_pci" "ahci" "sd_mod"
      "r8169" # the network interface driver for networking in the initial ramdisk
    ];
    kernelModules = [ "kvm-intel" ];
    loader.systemd-boot.enable = true;
    tmpOnTmpfs = true;

    kernelNetwork = {
      enable = true;
      ipv4 = builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0;
    };
  };

  fileSystems = {
    "${config.boot.loader.efi.efiSysMountPoint}" = {
      device = "/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_17071C5E48F5-part3";
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
    { device = "/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_17071C5E48F5-part2"; }
  ];
}
