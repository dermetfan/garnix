{ self, inputs, ... } @ parts:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.users;
in {
  imports = [ inputs.home-manager.nixosModule ];

  options.profiles.users = with lib; {
    enable = mkEnableOption "users";
    users = {
      root.enable = mkEnableOption "root" // {
        default = true;
      };
      dermetfan.enable = mkEnableOption "dermetfan";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users = {
        mutableUsers = false;
        defaultUserShell = pkgs.fish;
      };

      programs.fish.enable = true;

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        extraSpecialArgs = { inherit self; };
      };
    }

    (lib.mkIf cfg.users.root.enable {
      users.users.root.hashedPassword = "$6$9876543210987654$TOIH9KzZb/Tfa/0F2mobm4Hl2vwh5bFp8As6VFCaqSIu5KoqgdpESOmuMI04J8DUPGdvEjDMkWi9Lxqhu5gZ50";
    })

    (lib.mkIf cfg.users.dermetfan.enable {
      users.users.dermetfan = {
        description = "dermetfan.net";
        isNormalUser = true;
        hashedPassword = "$6$0123456789012345$h8FEllCQBQYziYvFVOhIqGRvt/z3lPO5wU.07Uz9Y/E2AvSUtq9ITQZTivMFN0gSSpFrDJ0P32k9t5uG4c47D0";
        extraGroups = with lib;
          optional config.security.sudo                 .enable "wheel"          ++
          optional config.programs.light                .enable "video"          ++
          optional config.networking.networkmanager     .enable "networkmanager" ++
          optional config.virtualisation.docker         .enable "docker"         ++
          optional config.virtualisation.podman         .enable "podman"         ++
          optional config.virtualisation.libvirtd       .enable "libvirtd"       ++
          optional config.virtualisation.virtualbox.host.enable "vboxusers"      ++
          optional config.programs.adb                  .enable "adbusers";
      };

      services.xserver.displayManager.slim = lib.mkIf (!lib.versionOlder "19.09" lib.version) {
        defaultUser = lib.mkDefault config.users.users.dermetfan.name;
      };

      home-manager.users = { inherit (parts.config.flake.homeManagerProfiles) dermetfan; };
    })
  ]);
}
