{ nixosConfig ? null, config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.wayland.windowManager.sway.enable.default = config.wayland.windowManager.sway.enable;

  config = {
    programs = {
      swappy  .enable = true;
      swaylock.enable = true;
      jq      .enable = true;
    };

    services.mako.enable = true;

    home.packages = with pkgs; [
      clipman wl-clipboard
      grim slurp
      wob alsaUtils
      libnotify
      bash
    ];

    wayland.windowManager.sway = {
      wrapperFeatures.gtk = true;

      customKeyboards = [
        "7504:24866:Ultimate_Gadget_Laboratories_UHK_60_v1"
        "43256:6195:Bastard_Keyboards_Charybdis_(4x6)_Elite-C"
      ];

      config = {
        input = {
          "type:keyboard" = {
            repeat_delay = "225";
            repeat_rate = "27";
          };
          "2:7:SynPS\/2_Synaptics_TouchPad" = {
            accel_profile = "adaptive";
            pointer_accel = "0.5";
          };
          "1118:57:Microsoft_Microsoft_5-Button_Mouse_with_IntelliEye(TM)" = {
            accel_profile = "adaptive";
            pointer_accel = "0.95";
          };
        };

        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
          wobShowVolume = ''printf "%d 282828D9 FB3934FF DBDBB2FF\n" $(amixer sget Master | grep -m 1 '\[on\]' | grep -E '\[[[:digit:]]{1,3}%\]' -o | grep -E '[[:digit:]]{1,3}' -o || echo 0) > $SWAYSOCK.wob'';
          wobShowBacklight = ''printf '%.0f 282828D9 DBDBB2FF DBDBB2FF\n' $(light -G) > $SWAYSOCK.wob'';
        in {
          "${mod}+c" = "exec clipman pick --tool rofi --max-items=50";

          "${mod}+k" = ''exec "swaymsg reload && timeout 1.75 swaynag -t warning -e bottom -m 'reloaded sway configuration'"'';
          "${mod}+Ctrl+k" = ''exec "swaynag -t warning -e bottom -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'"'';

          "Print" = ''exec grim -g "$(slurp)" - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';
          "Shift+Print" = ''exec grim - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';

          "${mod}+Grave" = lib.mkIf config.services.mako.enable ''exec makoctl dismiss'';
          "${mod}+Asciitilde" = lib.mkIf config.services.mako.enable ''exec makoctl restore'';

          "XF86AudioRaiseVolume" = "exec ${lib.optionalString (!(nixosConfig.sound.enable or false && nixosConfig.sound.mediaKeys.enable or false)) "amixer -q set Master 2%+ unmute &&"} ${wobShowVolume}";
          "XF86AudioLowerVolume" = "exec ${lib.optionalString (!(nixosConfig.sound.enable or false && nixosConfig.sound.mediaKeys.enable or false)) "amixer -q set Master 2%- unmute &&"} ${wobShowVolume}";
          "XF86AudioMute" =
            let
              toggle = ''(amixer sget Master | grep -m 1 -E '(Mono|Right|Left):' | grep '\[on\]' -q && amixer -q set Master mute || amixer -q set Master unmute)''; # FIXME works but seems to toggle twice
            in
              "exec ${lib.optionalString (!nixosConfig.sound.mediaKeys.enable or false) "amixer -q set Master mute &&"} ${wobShowVolume}";

          "XF86ScreenSaver"    = "exec swaylock";
          "${mod}+Scroll_Lock" = "exec swaylock";
        } // lib.optionalAttrs (!nixosConfig.misc.hotkeys.enableBacklightKeys) {
          "XF86MonBrightnessUp"         = "exec light -A 5 && ${wobShowBacklight}";
          "XF86MonBrightnessDown"       = "exec light -U 5 && ${wobShowBacklight}";
          "Shift+XF86MonBrightnessUp"   = "exec light -rA 1 && ${wobShowBacklight}";
          "Shift+XF86MonBrightnessDown" = "exec light -rU 1 && ${wobShowBacklight}";
        } // {
          "${mod}+Alt+Space" = let
            toggle = pkgs.writeScript "sway-toggle-keymap" ''
              #! ${pkgs.bash}/bin/bash

              while read ident; do
                  read index
                  read name
                  read layout
                  swaymsg input "$ident" xkb_switch_layout $index
                  msg+="$layout on $name\n"
              done < <(
                swaymsg -t get_inputs | \
                jq -r '
                map(select(.type == "keyboard" and (.xkb_layout_names | length) > 1))[] |
                ((.xkb_active_layout_index + 1) % (.xkb_layout_names | length)) as $index |
                .identifier, $index, .name, .xkb_layout_names[$index]
                '
              )

              notify-send -t 1500 'Toggled keyboard layout' "$msg"
            '';
          in "exec ${toggle}";
        };
      };

      extraConfig = ''
        seat seat0 hide_cursor 2500
        seat seat0 hide_cursor when-typing enable
        output * background ${config.xdg.configHome}/sway/background fill
        exec wl-paste --type text --watch clipman store --max-items=50
        exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob
      '';
    };
  };
}
