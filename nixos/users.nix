{ self, config, lib, pkgs, ... }:

{
  imports = [ self.inputs.home-manager.nixosModule ];

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    users = {
      root.hashedPassword = "$6$9876543210987654$TOIH9KzZb/Tfa/0F2mobm4Hl2vwh5bFp8As6VFCaqSIu5KoqgdpESOmuMI04J8DUPGdvEjDMkWi9Lxqhu5gZ50";

      dermetfan = {
        description = "dermetfan.net";
        isNormalUser = true;
        hashedPassword = "$6$0123456789012345$h8FEllCQBQYziYvFVOhIqGRvt/z3lPO5wU.07Uz9Y/E2AvSUtq9ITQZTivMFN0gSSpFrDJ0P32k9t5uG4c47D0";
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

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit self; };
    users.dermetfan = import ../home-manager;
  };
}
