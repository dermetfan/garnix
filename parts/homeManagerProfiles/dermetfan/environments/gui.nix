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
    xsession = {
      enable = nixosConfig.services.xserver.enable or false;
      windowManager.i3.enable = config.xsession.enable or false;
      initExtra = ''
        xset r rate 225 27
        xset m 5 1
        syndaemon -d -i 0.625 -K -R || :
      '';
    };

    gtk.enable = true;
    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    home = {
      sessionVariables.SUDO_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      
      packages = with pkgs;
        [
          x11_ssh_askpass
          libnotify
        ] ++
        lib.optionals config.xsession.enable [
          arandr
          xorg.xrandr
          xorg.xkill
          xclip
          xsel
        ] ++
        lib.optionals (!config.xsession.enable) [
          wdisplays
          wayvnc
        ];
    };

    services = {
      unclutter.enable = config.xsession.enable && !nixosConfig.services.unclutter.enable or false;
      picom.enable = config.xsession.enable && cfg.enableEffects;
    };

    wayland.windowManager.sway.enable = !config.xsession.enable;
    
    programs.swaylock.package = lib.mkIf cfg.enableEffects pkgs.swaylock-effects;

    # XXX https://github.com/nix-community/home-manager/pull/4707
    xdg.configFile."xdg-desktop-portal-wlr/config".text = lib.mkIf (
      nixosConfig.xdg.portal.enable or false &&
      builtins.elem pkgs.xdg-desktop-portal-wlr nixosConfig.xdg.portal.extraPortals or []
    ) (lib.generators.toINI {} {
      screencast = {
        max_fps = 30;
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -orf %o";
      };
    });
  };
}
