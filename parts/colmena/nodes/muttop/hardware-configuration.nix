{ inputs, ... }:

{ config, lib, ... }:

{
  imports = with inputs; [
    nixpkgs.nixosModules.notDetected
    disko.nixosModules.disko
  ];

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    printers = {
      ensureDefaultPrinter = "Brother_MFC-J4420DW";
      ensurePrinters = [
        {
          name = "Brother_MFC-J4420DW";
          deviceUri = "ipp://BRWC48E8FBE3AB4/ipp";
          model = "everywhere";
          ppdOptions.Duplex = "DuplexNoTumble";
        }
      ];
    };

    sane = {
      enable = true;
      brscan4.enable = true;
    };
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

  powerManagement.cpuFreqGovernor = "performance";

  fileSystems."/state".neededForBoot = true;

  disko.devices = {
    disk.root = {
      device = "/dev/disk/by-id/ata-JAJS600M1TB_AA000000000000001052";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "12G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "root";
            };
          };
        };
      };
    };
    zpool.root = {
      rootFsOptions = {
        compression = "zstd";
        acltype = "posix";
        xattr = "sa";
        mountpoint = "none";
      };

      postCreateHook = "zfs snapshot -r root@blank";

      datasets = lib.mapAttrs (_: v: v // {
        type = "zfs_fs";
        options = v.options or {} // lib.optionalAttrs (v ? "mountpoint") {inherit (v) mountpoint;};
      }) {
        reserved = {
          options = {
            refreserv = "1G";
            canmount = "off";
            mountpoint = "none";
          };
        };
        root.mountpoint = "/";
        nix.mountpoint = "/nix";
        home.mountpoint = "/home";
        state.mountpoint = "/state";
      };
    };
  };
}
