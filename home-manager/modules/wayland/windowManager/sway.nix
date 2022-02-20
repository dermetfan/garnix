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

    enableUHK = mkEnableOption "UHK input";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      config.input = {
        ${cfg.keyboardIdentifier} = with config.home.keyboard; {
          xkb_layout = layout;
          xkb_variant = variant;
          xkb_options = lib.concatStringsSep "," options;
        };

        "7504:24866:Ultimate_Gadget_Laboratories_UHK_60_v1" = lib.mkIf cfg.enableUHK {
          xkb_layout = config.home.keyboard.layout;
          xkb_variant = with lib; concatStringsSep "," (
            zipListsWith # remove variant for us layout (that is what UHK keymaps are for)
              (layout: optionalString (layout != "us"))
              (splitString "," config.home.keyboard.layout)
              (splitString "," config.home.keyboard.variant)
          );

          inherit (config.wayland.windowManager.sway.config.input."type:keyboard") repeat_delay repeat_rate;

          accel_profile = "flat";
          pointer_accel = "0";
        };
      };

      extraConfig = lib.optionalString (cfg.clamshellOutput != "") ''
        bindswitch --reload --locked lid:on output ${cfg.clamshellOutput} disable
        bindswitch --reload --locked lid:off output ${cfg.clamshellOutput} enable
      '';

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland

        # in case qt5.qtwayland is in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

        # FIXME fontconfig does not find its config file without this
        export FONTCONFIG_FILE=~/.config/fontconfig/conf.d/10-hm-fonts.conf
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
