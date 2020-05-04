{ config, lib, pkgs, ... }:

let
  cfg = config.config.wayland.windowManager.sway;
  sysCfg = config.passthru.systemConfig or {};
  common = import ./common.nix {
    inherit config lib;
    cfg = config.wayland.windowManager.sway;
  };
in {
  options.config.wayland.windowManager.sway = {
    enable = with lib; mkOption {
      type = types.bool;
      default = config.wayland.windowManager.sway.enable;
      description = "Whether to configure sway.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    common.config
    { wayland.windowManager.sway = common.i3-sway; }
    {
      programs = {
        swaylock.enable = true;
        mako    .enable = true;
      };

      home.packages = with pkgs; [
        clipman wl-clipboard
        grim slurp
        wob
      ];

      wayland.windowManager.sway = {
        wrapperFeatures.gtk = true;

        config = {
          input = {
            "type:keyboard" = {
              repeat_delay = "225";
              repeat_rate = "27";
            };
            "*" = {
              accel_profile = "adaptive";
              pointer_accel = "0.95";
            };
          };

          keybindings = let
            mod = config.wayland.windowManager.sway.config.modifier;
            wobShowVolume = ''(amixer sget Master | grep -m 1 -E '(Mono|Right|Left):' | grep '\[on\]' | grep -E '\[[[:digit:]][[:digit:]][[:digit:]]?%\]' -o | grep -E '[[:digit:]][[:digit:]][[:digit:]]?' -o || echo 0) > $SWAYSOCK.wob'';
          in {
            "${mod}+c" = "exec clipman pick -t rofi";

            "${mod}+k" = ''exec "swaymsg reload && timeout 1.75 swaynag -t warning -e bottom -m 'reloaded sway configuration'"'';
            "${mod}+Ctrl+k" = ''exec "swaynag -t warning -e bottom -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'"'';

            "Print" = ''exec grim -g "$(slurp)" "${config.xdg.userDirs.pictures}/$(date --iso-8601=ns)_grim.png"'';
            "Shift+Print" = ''exec grim "${config.xdg.userDirs.pictures}/$(date --iso-8601=ns)_grim.png"'';

            "Ctrl+Space" = lib.mkIf config.programs.mako.enable ''exec makoctl dismiss'';

            "XF86AudioRaiseVolume" = "exec ${lib.optionalString (!sysCfg.sound.mediaKeys.enable or false) "amixer -q set Master 2%+ unmute &&"} ${wobShowVolume}";
            "XF86AudioLowerVolume" = "exec ${lib.optionalString (!sysCfg.sound.mediaKeys.enable or false) "amixer -q set Master 2%- unmute &&"} ${wobShowVolume}";
            "XF86AudioMute" =
              let
                toggle = ''(amixer sget Master | grep -m 1 -E '(Mono|Right|Left):' | grep '\[on\]' -q && amixer -q set Master mute || amixer -q set Master unmute)''; # FIXME works but seems to toggle twice
              in
                "exec ${lib.optionalString (!sysCfg.sound.mediaKeys.enable or false) "amixer -q set Master mute &&"} ${wobShowVolume}";

            "XF86ScreenSaver"    = "exec swaylock";
            "${mod}+Scroll_Lock" = "exec swaylock";
          };
        };

        extraConfig = ''
          seat seat0 hide_cursor 2500
          output * background ${config.xdg.configHome}/sway/background fill
          exec wl-paste -t text -w clipman store
          exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob
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
    }
  ]);
}
