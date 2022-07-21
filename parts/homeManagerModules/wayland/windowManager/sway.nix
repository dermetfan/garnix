{ config, lib, ... }:

let
  cfg = config.wayland.windowManager.sway;
in {
  options.wayland.windowManager.sway = with lib; {
    keyboardIdentifier = mkOption {
      type = types.str;
      default = "type:keyboard";
      description = ''
        Input device identifier to apply <option>home.keyboard</option> options to.
        Change this if you do not want those applied on all keyboards.
      '';
    };

    clamshellOutput = mkOption {
      type = types.str;
      default = "";
      description = ''
        Output to disable when the lid is closed.
      '';
    };

    customKeyboards = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        Input identifiers of custom keyboards.
        These will have no pointer acceleration set
        and the default keymap variant removed as
        such settings are configured on the keyboard itself.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      config.input = {
        ${cfg.keyboardIdentifier} = with config.home.keyboard; {
          xkb_layout = layout;
          xkb_variant = variant;
          xkb_options = builtins.concatStringsSep "," options;
        };
      } // lib.genAttrs cfg.customKeyboards (identifier: {
        xkb_layout = config.home.keyboard.layout;
        xkb_variant = with lib; concatStringsSep "," (
          zipListsWith # remove variant for us layout (that is what the board's keymap is for)
            (layout: optionalString (layout != "us"))
            (splitString "," config.home.keyboard.layout)
            (splitString "," config.home.keyboard.variant)
        );
        xkb_options = builtins.concatStringsSep "," config.home.keyboard.options;

        inherit (config.wayland.windowManager.sway.config.input."type:keyboard") repeat_delay repeat_rate;

        accel_profile = "flat";
        pointer_accel = "0";
      });

      extraConfig = lib.optionalString (cfg.clamshellOutput != "") ''
        bindswitch --reload --locked lid:on output ${cfg.clamshellOutput} disable
        bindswitch --reload --locked lid:off output ${cfg.clamshellOutput} enable
      '';

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland

        # in case qt5.qtwayland is in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      '';
    };

    # TODO remove once using a recent enough home-manager version
    # https://github.com/nix-community/home-manager/issues/2064
    systemd.user.targets.tray.Unit = {
      Description = "Home Manager System Tray";
      BindsTo = [ "sway-session.target" ];
    };
  };
}
