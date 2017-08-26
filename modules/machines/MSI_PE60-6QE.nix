# Tested on: MSI PE60-6QEI781
{ config, lib, pkgs, ... }:

let
  cfg = config.config.machine."MSI PE60-6QE";

  bumblebeeHack = pkgs.writeScript "bumblebeed.sh" ''
    ${pkgs.bumblebee}/bin/bumblebeed -Dg ${config.users.groups.wheel.name}
  '';
in {
  options.config.machine."MSI PE60-6QE" = {
    enable = lib.mkEnableOption "MSI PE60-6QE";

    hyperThreading = with lib; mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether Hyper-Threading is enabled.

        Sets <literal>nix.maxJobs</literal> and <literal>nix.buildCores</literal> to 8, otherwise 4.
      '';
    };

    enableBumblebeeHack = lib.mkEnableOption "the Bumblebee hack to turn off the dedicated GPU";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sr_mod"
        "rtsx_usb_sdmmc"
      ];

      kernelModules = [ "kvm-intel" ] ++
        lib.optional cfg.enableBumblebeeHack "bbswitch";

      blacklistedKernelModules = [
        "nouveau" # causes CPU stalls with intel GPU driver
      ];

      extraModulePackages = with pkgs.linuxPackages;
        lib.optional cfg.enableBumblebeeHack bbswitch;

      tmpOnTmpfs = true;
    };

    nix = {
      maxJobs = if cfg.hyperThreading then 8 else 4;
      buildCores = if cfg.hyperThreading then 8 else 4;
    };

    hardware = {
      enableAllFirmware = true;
#      nvidiaOptimus.disable = true;
#      bumblebee.enable = true;
      opengl.driSupport32Bit = true;
      bluetooth.enable = true;
      pulseaudio = {
        package = pkgs.pulseaudioFull;
        support32Bit = true;
      };
    };

    security.sudo.extraConfig = lib.optionalString cfg.enableBumblebeeHack ''
      %${config.users.groups.wheel.name} ALL=(ALL:ALL) NOPASSWD:${bumblebeeHack}
    '';

    services.xserver = {
      displayManager.sessionCommands = lib.optionalString cfg.enableBumblebeeHack ''
        sudo ${bumblebeeHack}
      '';

      videoDrivers = [ "intel" ];
    };
  };
}
