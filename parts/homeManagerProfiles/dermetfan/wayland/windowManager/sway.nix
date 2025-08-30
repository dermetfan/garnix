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

    home.packages = with pkgs;
      [
        clipman wl-clipboard
        grim slurp
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

        left  = "n";
        right = "o";
        up    = "r";
        down  = "i";

        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
          notifyVolume = pkgs.writers.writeNu "sway-notify-volume" ''
            let info = ${lib.getExe' pkgs.wireplumber "wpctl"} get-volume @DEFAULT_AUDIO_SINK@
            | parse --regex '\w+:\s+(?<volume>\d+(\.\d+)?)(\s+(?<muted>\[MUTED\]))?'
            | get 0
            | select volume muted
            | update volume {
              into float
              | $in * 100
              | into int
            }
            | update muted {is-not-empty}

            let icon = if $info.muted {
              '🔇'
            } else if $info.volume < 33 {
              '🔈'
            } else if $info.volume < 66 {
              '🔉'
            } else {
              '🔊'
            }

            (
              notify-send
              --category ${lib.escapeShellArg config.profiles.dermetfan.services.mako.desktop.category}
              --app-name ${lib.escapeShellArg config.profiles.dermetfan.services.mako.desktop.progressApp}
              --expire-time 1500
              --urgency low
              --hint $'INT:value:($info.volume)'
              $'($icon) Volume'
              (
                $'($info.volume)%'
                + if $info.muted {
                  ' (muted)'
                } else {'''}
              )
            )
          '';
        in {
          "${mod}+c" = "exec clipman pick --tool rofi --max-items=50";

          "${mod}+k" = "exec swaymsg reload && timeout 1.75 swaynag -t warning -e bottom -m 'reloaded sway configuration'";
          "${mod}+Ctrl+k" = "exec swaynag -t warning -e bottom -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

          "Print" = ''exec grim -g "$(slurp)" - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';
          "Shift+Print" = ''exec grim - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';

          "${mod}+Grave" = lib.mkIf config.services.mako.enable ''exec makoctl dismiss'';
          "${mod}+Asciitilde" = lib.mkIf config.services.mako.enable ''exec makoctl restore'';
          "${mod}+Alt+Grave" = lib.mkIf config.services.mako.enable (
            let
              mode = "do-not-disturb";
              modeHuman = builtins.replaceStrings [ "-" ] [ " " ] mode;
            in
            assert config.services.mako.settings ? "mode=${mode}";
            "exec " + pkgs.writers.writeNu "sway-toggle-do-not-disturb" ''
              makoctl mode -t ${lib.escapeShellArg mode}

              def --wrapped notify [...args]: nothing -> nothing {
                (
                  notify-send
                  --category ${lib.escapeShellArg config.profiles.dermetfan.services.mako.desktop.category}
                  --expire-time 1500
                  ...$args
                )
              }

              if ${lib.escapeShellArg mode} in (makoctl mode | lines) {
                notify '🔕 Notifications hidden' ${lib.escapeShellArg ''"${modeHuman}" mode enabled''}
              } else {
                notify '🔔 Notifications shown' ${lib.escapeShellArg ''"${modeHuman}" mode disabled''}
              }
            ''
          );
        } // builtins.mapAttrs (_: wpctlArgs: toString (
          [ "exec" ]
          ++ lib.optionals
          (!nixosConfig.misc.hotkeys.sound.enable or false)
          [
            (lib.getExe' pkgs.wireplumber "wpctl")
            wpctlArgs
            "&&"
          ]
          ++ [ notifyVolume ]
        )) {
          "XF86AudioRaiseVolume" = "set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 2%+";
          "XF86AudioLowerVolume" = "set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          "XF86AudioMute" = "set-mute @DEFAULT_AUDIO_SINK@ toggle";
        } // {
          "XF86ScreenSaver"    = "exec swaylock";
          "${mod}+Scroll_Lock" = "exec swaylock";
        } // (let
          systemWide = with nixosConfig.programs.light; enable && brightnessKeys.enable;
          notifyBrightness = pkgs.writers.writeNu "sway-notify-brightness" ''
            let brightness = light -G | into int

            let icon = if $brightness >= 50 {
              '🔆'
            } else {
              '🔅'
            }

            (
              notify-send
              --category ${lib.escapeShellArg config.profiles.dermetfan.services.mako.desktop.category}
              --app-name ${lib.escapeShellArg config.profiles.dermetfan.services.mako.desktop.progressApp}
              --expire-time 1500
              --urgency low
              --hint $'INT:value:($brightness)'
              $'($icon) Brightness'
              $'($brightness)%'
            )
          '';
        in {
          "XF86MonBrightnessUp"   = "exec ${lib.optionalString (!systemWide) "light -A 5 &&"} ${notifyBrightness}";
          "XF86MonBrightnessDown" = "exec ${lib.optionalString (!systemWide) "light -U 5 &&"} ${notifyBrightness}";
        }) // {
          "${mod}+Alt+Space" = "exec " + pkgs.writers.writeNu "sway-toggle-keymap" ''
            let targets = swaymsg -t get_inputs
            | from json
            | where type == keyboard
            | filter {($in.xkb_layout_names | length) > 1}
            | each {
              let xkb_active_layout_index = ($in.xkb_active_layout_index + 1) mod ($in.xkb_layout_names | length)
              {
                identifier: $in.identifier
                xkb_active_layout_index: $xkb_active_layout_index
                name: $in.name
                xkb_layout_name: ($in.xkb_layout_names | get $xkb_active_layout_index)
              }
            }

            for target in $targets {
              swaymsg input $target.identifier xkb_switch_layout $target.xkb_active_layout_index
            }

            ${lib.getExe pkgs.libnotify} -t 1500 '⌨️ Changed keyboard layout' (
              if ($targets | length) == 1 {
                $targets.0.xkb_layout_name
              } else {
                $targets
                | each {$'($in.name): ($in.xkb_layout_name)'}
                | str join "\n"
              }
            )
          '';
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
