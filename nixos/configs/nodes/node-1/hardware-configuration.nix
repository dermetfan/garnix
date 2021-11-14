{ self, ... }:

{
  imports = [ self.inputs.nixpkgs.nixosModules.notDetected ];

  networking = {
    hostId = "8949dfd2";

    interfaces = {
      enp2s0 = {
        macAddress = "4e:65:64:54:7a:19";
        useDHCP = true;
      };
      enp5s4 = {
        macAddress = "00:18:f3:46:c0:3c";
        useDHCP = true;
      };
    };
  };

  boot = {
    initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "ahci" "pata_jmicron" "firewire_ohci" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];

    loader.grub = {
      enable = true;
      devices = [
        "/dev/disk/by-id/ata-ST380817AS_5MR3CBDQ"
        "/dev/disk/by-id/ata-ST380817AS_5MR39JYX"
      ];
      zfsSupport = true;
    };
  };

  fileSystems."/" = {
    device = "root";
    fsType = "zfs";
  };

  nix.maxJobs = 2;

  powerManagement.cpuFreqGovernor = "ondemand";
}
