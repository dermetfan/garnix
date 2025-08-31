{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.environments.gui;
in {
  options.profiles.dermetfan.environments.gui = with lib; {
    enable.default = false;

    enableEffects = mkOption {
      type = types.bool;
      description = "Whether to enable effects.";
      default = true;
    };
  };

  config = {
    gtk.enable = true;
    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };

    home = {
      sessionVariables.SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      
      packages = with pkgs;
        [
          x11_ssh_askpass
          libnotify
          wdisplays
          wayvnc
        ];
    };

    wayland.windowManager.sway.enable = true;
    
    programs.swaylock.package = lib.mkIf cfg.enableEffects pkgs.swaylock-effects;

    xdg = {
      portal = {
        enable = !nixosConfig.xdg.portal.enable;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
        ];
        config.common.default = "*";
      };

      configFile."xdg-desktop-portal-wlr/config" = lib.mkIf (
        (config.xdg.portal.enable && builtins.elem pkgs.xdg-desktop-portal-wlr config.xdg.portal.extraPortals) ||
        (nixosConfig.xdg.portal.enable or false && builtins.elem pkgs.xdg-desktop-portal-wlr nixosConfig.xdg.portal.extraPortals or [])
      ) {
        text = (lib.generators.toINI {} {
          screencast = {
            max_fps = 30;
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -orf %o";
          };
        });
      };
    };
  };
}
