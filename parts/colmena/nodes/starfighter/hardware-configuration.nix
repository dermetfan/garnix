{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = with inputs; [
    nixpkgs.nixosModules.notDetected
    disko.nixosModules.disko
    disko-zfs.nixosModules.default
  ];

  home-manager.users.dermetfan = {
    profiles.dermetfan.programs.i3status-rust.batteries = [ "BAT0" ];

    wayland.windowManager.sway = {
      keyboardIdentifier = "1:1:AT_Translated_Set_2_keyboard";
      clamshellOutput = "eDP-1";
    };
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "rtsx_usb_sdmmc" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    zfs = {
      forceImportRoot = false;
      allowHibernation = true;
    };
  };

  hardware = {
    facter.reportPath = ./facter.json;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    bluetooth.enable = true;
  };

  fileSystems."/state".neededForBoot = true;

  disko.devices = let
    luks = {
      enrollFido2 = true;
      extraFido2EnrollArgs = lib.cli.toGNUCommandLine {} {
        fido2-with-client-pin = builtins.toJSON true;
        fido2-with-user-presence = builtins.toJSON true;
      };

      # optimize for SSD
      settings = {
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };
  in {
    disk = {
      root = {
        device = "/dev/disk/by-id/nvme-eui.0025384351447b59";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            swap = {
              size = lib.pipe config.hardware.facter.reportPath [
                lib.importJSON
                (report: report.smbios.memory_device)
                (lib.fold ({ size, ... }: total: total + size) 0)
                (memoryKib: memoryKib / 1024 / 1024)
                (memoryGib: toString memoryGib + "G")
              ];
              content = luks // {
                type = "luks";
                name = "swap";
                content.type = "swap";
              };
            };

            root = {
              size = "100%";
              content = luks // {
                type = "luks";
                name = "root";
                content = {
                  type = "zfs";
                  pool = "root";
                };
              };
            };
          };
        };
      };

      tank = {
        device = "/dev/disk/by-id/nvme-eui.0025384651a40387";
        content = luks // {
          type = "luks";
          name = "tank";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
    };

    zpool = let
      mkDatasets = lib.mapAttrs (_: v: v // {
        type = v.type or "zfs_fs";
        options =
          lib.optionalAttrs (v ? "mountpoint") {inherit (v) mountpoint;}
          // v.options or {};
      });
    in {
      root = {
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posix";
          xattr = "sa";
        };

        postCreateHook = ''
          zfs snapshot -r root@blank
          zfs hold -r blank root@blank
        '';

        datasets = mkDatasets {
          reserved.options = {
            refreserv = "${toString (builtins.floor (4 * 1024 * 0.2))}G"; # 20% of 4T because ZFS becomes slow at 80% usage
            canmount = "off";
          };

          root.mountpoint = "/";
          nix.mountpoint = "/nix";
          home.mountpoint = "/home";
          state.mountpoint = "/state";
        };
      };

      tank = {
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posix";
          xattr = "sa";
        };

        datasets = mkDatasets {
          reserved.options = {
            refreserv = "${toString (builtins.floor (4 * 1024 * 0.2))}G"; # 20% of 4T because ZFS becomes slow at 80% usage
            canmount = "off";
          };
        };
      };
    };
  };
}
