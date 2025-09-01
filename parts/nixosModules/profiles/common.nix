{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.common;
in {
  imports = with inputs; [
    hosts.nixosModule
    programs-sqlite.nixosModules.programs-sqlite
    stylix.nixosModules.stylix
  ];

  options.profiles.common.enable = lib.mkEnableOption "common settings";

  config = lib.mkMerge [
    { programs-sqlite.enable = cfg.enable && config.programs.command-not-found.enable; }

    (lib.mkIf cfg.enable {
      defaults.enable = true;

      profiles.users.enable = true;

      stylix = {
        enable = true;

        base16Scheme = pkgs.base16-schemes + /share/themes/gruvbox-dark-hard.yaml;
        image = inputs.gruvbox-wallpapers + /forest-hut.png;
        polarity = "dark";

        fonts = {
          sizes.desktop = config.stylix.fonts.sizes.applications;

          monospace = {
            package = pkgs.nerd-fonts.fira-code;
            name = "FiraCode Nerd Font Mono";
          };
        };

        icons = rec {
          enable = true;
          package = pkgs.kdePackages.breeze-icons;
          light = "breeze";
          dark = light + "-dark";
        };

        opacity.terminal = 0.8;
      };

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
          hostKeys = [
            rec { type = "ed25519"; path = "/etc/ssh/ssh_host_${type}_key"; }
          ];
        };

        "1.1.1.1".enable = true;

        zfs.autoScrub.enable = true;
        znapzend.enable = lib.mkDefault config.boot.zfs.enabled;
      };
    })
  ];
}
