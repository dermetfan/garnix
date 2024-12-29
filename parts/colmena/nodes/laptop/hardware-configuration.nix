{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [ inputs.nixpkgs.nixosModules.notDetected ];

  home-manager.users.dermetfan = {
    profiles.dermetfan.programs.i3status-rust.batteries = [ "BAT1" ];

    wayland.windowManager.sway = {
      keyboardIdentifier = "1:1:AT_Translated_Set_2_keyboard";
      clamshellOutput = "eDP-1";
    };
  };

  hardware = {
    "MSI PE60-6QE" = {
      enable = true;
      enableGPU = false;
    };
    nvidia.open = false;
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
