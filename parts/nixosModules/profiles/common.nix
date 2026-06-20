{ inputs, moduleWithSystem, ... }:

moduleWithSystem ({self'}: { options, config, lib, pkgs, ... }: let
  cfg = config.profiles.common;
in {
  imports = with inputs; [
    hosts.nixosModule
  ];

  options.profiles.common.enable = lib.mkEnableOption "common settings";

  config = lib.mkIf cfg.enable {
    defaults.enable = true;

    profiles.users.enable = true;

    nix = {
      settings = {
        trusted-public-keys = [
          (builtins.readFile ../../../secrets/services/cache.pub)
        ];

        system-features = lib.mkDefault [ "recursive-nix" ];

        experimental-features = [ "nix-command" "flakes" "recursive-nix" "impure-derivations" "ca-derivations" "fetch-closure" ];
      };
    };

    time.timeZone = "Europe/Berlin";

    networking.stevenBlackHosts.enable = true;

    environment = {
      sessionVariables.XKB_CONFIG_ROOT = config.services.xserver.xkb.dir; # for wayland

      systemPackages = lib.optional config.boot.supportedFilesystems.zfs pkgs.zfs-holds;
    };

    security.acme.defaults.email = "serverkorken@gmail.com";

    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      fontconfig.enable = true;
      enableGhostscriptFonts = true;
    };

    programs = {
      mosh.enable = true;
      tmux.enable = true;
    };

    services = {
      openssh = {
        enable = true;
        hostKeys = lib.mkDefault (
          builtins.filter
          ({ type, ... }: type == "ed25519")
          options.services.openssh.hostKeys.default
        );
      };

      "1.1.1.1".enable = true;

      xserver.xkb.dir = "${self'.packages.xkeyboard_config}/etc/X11/xkb";

      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };

      znapzend = {
        pure = true;
        features = {
          oracleMode = true;
          recvu = true;
          zfsGetType = true;
        };
      };
    };

    # Remove public host keys. They are just confusing and unnecessary.
    systemd.services.${"sshd" + lib.optionalString config.services.openssh.startWhenNeeded "@"}.preStart = lib.mkAfter (
      lib.concatMapStringsSep "\n"
      (key: "rm --force ${lib.escapeShellArg key.path}.pub")
      config.services.openssh.hostKeys
    );
  };
})
