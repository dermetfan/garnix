{ inputs, ... }:

{ config, lib, pkgs, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
  ];

  system.stateVersion = "25.05";

  profiles = {
    handson.enable = true;
    hardening.enable = true;
    notebook.enable = true;
    gui.enable = true;
    dev.enable = true;
    users = {
      enable = true;
      users.dermetfan.enable = true;
    };
    afraid-freedns.enable = true;
    yggdrasil.enable = true;
  };

  programs.light.brightnessKeys.enable = lib.mkForce false; # handled by sway config

  # for i3status-rust eco block
  security.sudo.extraRules = lib.mkAfter [
    {
      commands = [ {
        command = lib.getExe config.services.tlp.package;
        options = [ "NOPASSWD" ];
      } ];
      groups = [ config.users.groups.wheel.gid ];
    }
  ];

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    znapzend = {
      enable = true;
      zetup = let
        planFew = "1week=>1day,1month=>1week";
      in lib.mapAttrs (k: v: {
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
      } // v) {
        "root".plan = planFew;
      };
    };
  };

  home-manager.users.dermetfan = {
    profiles.dermetfan.environments = {
      admin.enable = true;
      dev = {
        enable = true;
        enableRust = true;
        enableWeb = true;
      };
      iog.enable = true;
      media.enableEditors = true;
      office.enable = true;
      gui.enable = true;
      desktop.enable = true;
    };

    home.stateVersion = "25.05";

    services.wlsunset = config.passthru.coords or {};

    programs.firefox.hideTabs = true;
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
}
