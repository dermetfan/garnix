{ self, config, lib, pkgs, ... }:

let
  cfg = config.profiles.users;
in {
  imports = [ self.inputs.home-manager.nixosModule ];

  options.profiles.users.enable = lib.mkEnableOption "users";

  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.fish;

      users = {
        dermetfan = {
          description = "dermetfan.net";
          isNormalUser = true;
          extraGroups = with lib;
            optional config.security.sudo                 .enable "wheel"          ++
            optional config.programs.light                .enable "video"          ++
            optional config.networking.networkmanager     .enable "networkmanager" ++
            optional config.virtualisation.docker         .enable "docker"         ++
            optional config.virtualisation.virtualbox.host.enable "vboxusers"      ++
            optional config.programs.adb                  .enable "adbusers";
        };
      };
    };

    services.xserver.displayManager.slim = lib.mkIf (!lib.versionOlder "19.09" lib.version) {
      defaultUser = lib.mkDefault config.users.users.dermetfan.name;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit self; };
      users.dermetfan = import ../../../home-manager;
    };
  };
}
