{ self, nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.environments.gui;
in {
  imports = [
    self.inputs.xdg-desktop-portal-termfilepickers.homeManagerModules.default
    { services.xdg-desktop-portal-termfilepickers.package = self.inputs.xdg-desktop-portal-termfilepickers.packages.${pkgs.stdenv.system}.default; }
  ];

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
      platformTheme.name = lib.mkDefault "gtk";
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
    
    programs = {
      firefox.enable = true;

      swaylock.package = lib.mkIf cfg.enableEffects pkgs.swaylock-effects;
    };

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
        text = lib.generators.toINI {} {
          screencast = {
            max_fps = 30;
            chooser_type = "simple";
            # We need to prepend the output of slurp with "Monitor: " until this PR hits nixpkgs:
            # https://github.com/emersion/xdg-desktop-portal-wlr/pull/355
            # For details, see:
            # https://github.com/emersion/xdg-desktop-portal-wlr/issues/350
            chooser_cmd = lib.getExe (pkgs.writeShellApplication {
              name = "chooser";
              runtimeInputs = with pkgs; [ slurp ];
              text = ''
                output=$(slurp -orf %o)
                printf '%s' "Monitor: $output"
              '';
            });
          };
        };
      };
    };

    services.xdg-desktop-portal-termfilepickers = {
      enable = true;
      config.terminal_command =
        [ config.home.sessionVariables.TERMINAL ]
        ++ lib.optionals (builtins.elem config.home.sessionVariables.TERMINAL [ "foot" "footclient" ]) [ "--title" "Choose File" ];
    };

    # So that it can find its `terminal_command`.
    systemd.user.services.xdg-desktop-portal-termfilepickers.Service.PassEnvironment = [ "PATH" ];
  };
}
