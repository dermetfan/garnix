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

        icons = {
          enable = true;
        } // {
          # These are all nice so I'll keep them here for later.

          breeze = rec {
            package = pkgs.kdePackages.breeze-icons;
            light = "breeze";
            dark = light + "-dark";
          };

          colloid = {
            package = pkgs.colloid-icon-theme.override {
              schemeVariants = [ "gruvbox" ];
              colorVariants = [ "orange" ];
            };
            light = "Colloid-Orange-Gruvbox-Light";
            dark  = "Colloid-Orange-Gruvbox-Dark";
          };

          gruvbox = {
            package = pkgs.gruvbox-plus-icons.override {
              folder-color = "orange";
            };
            dark = "Gruvbox-Plus-Dark";
          };
        }.gruvbox;

        cursor = {
          # These are all nice so I'll keep them here for later.

          vanilla = {
            package = pkgs.vanilla-dmz;
            name = "DMZ-Black";
            size = 24;
          };

          breeze = {
            package = pkgs.kdePackages.breeze;
            name = "breeze_cursors";
            size = 24;
          };

          simp1e = {
            package = pkgs.simp1e-cursors;
            name = "Simp1e-Gruvbox-Dark";
            size = 24;
          };

          capitaine = {
            package = pkgs.capitaine-cursors-themed;
            name = "Capitaine Cursors (Gruvbox)";
            size = 24;
          };

          phinger = {
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-dark";
            size = 24;
          };
        }.simp1e;

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
