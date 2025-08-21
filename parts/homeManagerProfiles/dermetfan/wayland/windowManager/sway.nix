{ nixosConfig ? null, config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.wayland.windowManager.sway.enable.default = config.wayland.windowManager.sway.enable;

  config = {
    programs = {
      swappy  .enable = true;
      swaylock.enable = true;
      jq      .enable = true;
    };

    services = {
      mako.enable = true;

      wob = {
        enable = true;
        settings = {
          "" = {
            background_color = "282828D9";
            bar_color = "DBDBB2FF";
          };
          "style.volume".border_color = "FB3934FF";
          "style.backlight".border_color = "DBDBB2FF";
        };
      };
    };

    home.packages = with pkgs;
      [
        clipman wl-clipboard
        grim slurp
        wob alsa-utils
        libnotify
        bash
      ] ++
      lib.optional (!nixosConfig.programs.light.enable) light;

    wayland.windowManager.sway = {
      systemd.xdgAutostart = true;

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

        output."*".background = "${config.xdg.configHome}/sway/background fill";

        seat."*" = {
          hide_cursor = toString 2500;
          # XXX `seat."*"` should be a list. Fix upstream?
          # Since we cannot declare the `hide_cursor` key twice,
          # append a space that is ignored in the resulting `sway.conf` anyway.
          "hide_cursor " = "when-typing enable";
        };

        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
          # XXX use wireplumber for this. example: https://github.com/nix-community/home-manager/issues/3993#issuecomment-1554484665
          wobShowVolume = ''printf '%d volume\n' $(amixer sget Master | grep -m 1 '\[on\]' | grep -E '\[[[:digit:]]{1,3}%\]' -o | grep -E '[[:digit:]]{1,3}' -o || echo 0) > $XDG_RUNTIME_DIR/wob.sock'';
        in {
          "${mod}+c" = "exec clipman pick --tool rofi --max-items=50";

          "${mod}+k" = "exec swaymsg reload && timeout 1.75 swaynag -t warning -e bottom -m 'reloaded sway configuration'";
          "${mod}+Ctrl+k" = "exec swaynag -t warning -e bottom -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

          "Print" = ''exec grim -g "$(slurp)" - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';
          "Shift+Print" = ''exec grim - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';

          "${mod}+Grave" = lib.mkIf config.services.mako.enable ''exec makoctl dismiss'';
          "${mod}+Asciitilde" = lib.mkIf config.services.mako.enable ''exec makoctl restore'';
          "${mod}+Alt+Grave" = lib.mkIf config.services.mako.enable (
            let mode = "do-not-disturb"; in
            assert config.services.mako.settings ? "mode=${mode}";
            "exec makoctl mode -t ${mode}"
          );

          "XF86AudioRaiseVolume" = "exec ${lib.optionalString (!nixosConfig.misc.hotkeys.sound.enable or false) "amixer -q set Master 2%+ unmute &&"} ${wobShowVolume}";
          "XF86AudioLowerVolume" = "exec ${lib.optionalString (!nixosConfig.misc.hotkeys.sound.enable or false) "amixer -q set Master 2%- unmute &&"} ${wobShowVolume}";
          "XF86AudioMute" =
            let
              toggle = ''(amixer sget Master | grep -m 1 -E '(Mono|Right|Left):' | grep '\[on\]' -q && amixer -q set Master mute || amixer -q set Master unmute)''; # FIXME works but seems to toggle twice
            in
              "exec ${lib.optionalString (!nixosConfig.misc.hotkeys.sound.enable or false) "amixer -q set Master mute &&"} ${wobShowVolume}";

          "XF86ScreenSaver"    = "exec swaylock";
          "${mod}+Scroll_Lock" = "exec swaylock";
        } // (let
          systemWide = with nixosConfig.programs.light; enable && brightnessKeys.enable;
          wobShowBacklight = ''printf '%.0f backlight\n' $(light -G) > $XDG_RUNTIME_DIR/wob.sock'';
        in {
          "XF86MonBrightnessUp"   = "exec ${lib.optionalString (!systemWide) "light -A 5 &&"} ${wobShowBacklight}";
          "XF86MonBrightnessDown" = "exec ${lib.optionalString (!systemWide) "light -U 5 &&"} ${wobShowBacklight}";
        }) // {
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
        exec wl-paste --type text --watch clipman store --max-items=50
      '';

      # fails as it is not able to access the background image
      checkConfig = false;
    };
  };
}
