{ self, inputs, ... } @ parts:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.users;
in {
  imports = [ inputs.home-manager.nixosModules.default ];

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

      security.pam.u2f = {
        enable = true;
        settings = {
          cue = true;
          origin = "pam://${config.networking.domain}";
          authfile = builtins.toFile "u2f_keys" (
            lib.concatMapStringsSep "\n" (lib.concatStringsSep ":") [
              # generated using `pamu2fcfg --username dermetfan --origin pam://dermetfan.net`
              (lib.optionals cfg.users.dermetfan.enable [
                config.users.users.dermetfan.name
                # YubiKey 5 Nano
                "V6D9lVaa2iVhIJVFmcEYIRXZQ7sq+/sd0CHPkgVqIqh3lZWXDuYhsTvTkUIPYYXAlYpbuhXs5X1CKIwp5ZLQsQ==,lFGmV4LyY6renmWVW+Iz7vGrbjLdYbLdjfbbobu6+5prHHqtxQCA4Cghxr7gT7B3zMBq5qCckJI74uao4ivptg==,es256,+presence"
                # YubiKey 5 NFC
                "vl3AcisTTpW02+e4FeiNVvjLGorjBfae//7RACvZjj7xI2SLXtF7X9A/pCagkdf59T/Kg+C83U8SPSXnG8MpZg==,0FJywoW+q2vfbYBoJ+kfxgPmwIrG/KFcjfL4gIDzkRmfdRz33lSDajj/a3CIfP/lBw9Tt8GWezQxs097CZmw1g==,es256,+presence"
              ])
            ]
          );
        };
      };

      hardware.yubikey.enable = true;

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

        openssh.authorizedKeys.keyFiles = config.users.users.root.openssh.authorizedKeys.keyFiles or [];
      };

      home-manager.users = { inherit (parts.config.flake.homeManagerProfiles) dermetfan; };
    })
  ]);
}
