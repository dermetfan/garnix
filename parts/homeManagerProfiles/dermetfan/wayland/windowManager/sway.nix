{ nixosConfig ? null, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.wayland.windowManager.sway;
in {
  options.profiles.dermetfan.wayland.windowManager.sway = {
    enable.default = config.wayland.windowManager.sway.enable;

    enableGaps = lib.mkEnableOption "gaps config" // {
      default = true;
    };
  };

  config = {
    programs = {
      swappy  .enable = true;
      swaylock.enable = true;
      jq      .enable = true;

      i3status-rust.enable = true;
      foot         .enable = true;
      ranger       .enable = true;
      rofi         .enable = true;

      networkmanager-dmenu.enable = nixosConfig.networking.networkmanager.enable or false;
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

      extraConfig = ''
        exec wl-paste --type text --watch clipman store --max-items=50
      '';

      # fails as it is not able to access the background image
      checkConfig = false;

      config = lib.mkMerge [
        {
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

          focus.followMouse = false;

          window = {
            titlebar = false;
            border = 1;
            hideEdgeBorders = "both";
          };

          floating = {
            titlebar = false;
            border = config.wayland.windowManager.sway.config.window.border;
          };

          assigns."10" = [
            { class = "^TelegramDesktop$"; }
            { class = "^HipChat$"; }
            { class = "^skypeforlinux$"; }
            { instance = "^WeeChat$"; }
          ];

          bars = [ {
            fonts = config.wayland.windowManager.sway.config.fonts;
            mode = "hide";
            workspaceNumbers = false;
            statusCommand = "i3status-rs " + config.profiles.dermetfan.programs.i3status-rust.barConfigFiles.default;
            trayOutput = "*";
            colors.background = "00000088";
            extraConfig = ''
              status_padding 0
              colors {
                focused_background 000000CC
              }
            '';
          } ];

          terminal = config.home.sessionVariables.TERMINAL;

          modifier = "Mod4";

          keybindings = let
            inherit (config.wayland.windowManager.sway.config)
              modifier
              left
              right
              up
              down
              terminal;

            floatingMoveStep = "25px";

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
            "${modifier}+Return" = "exec ${terminal}";

            "${modifier}+x" = "exec ${terminal} -e ranger";
            "${modifier}+Shift+x" = "exec ${terminal} -e sudo ranger";

            "${modifier}+e"       = "exec rofi -show drun";
            "${modifier}+Shift+e" = "exec rofi -show combi";
            "${modifier}+Tab"     = "exec rofi -show window";

            "${modifier}+m" = lib.mkIf config.programs.networkmanager-dmenu.enable "exec networkmanager_dmenu";

            "${modifier}+q" = "kill";

            "${modifier}+${left}"  = "focus left";
            "${modifier}+${right}" = "focus right";
            "${modifier}+${up}"    = "focus up";
            "${modifier}+${down}"  = "focus down";
            "${modifier}+Left"  = "focus left";
            "${modifier}+Right" = "focus right";
            "${modifier}+Up"    = "focus up";
            "${modifier}+Down"  = "focus down";

            "${modifier}+Shift+${left}"  = "move left ${floatingMoveStep}";
            "${modifier}+Shift+${right}" = "move right ${floatingMoveStep}";
            "${modifier}+Shift+${up}"    = "move up ${floatingMoveStep}";
            "${modifier}+Shift+${down}"  = "move down ${floatingMoveStep}";
            "${modifier}+Shift+Left"  = "move left ${floatingMoveStep}";
            "${modifier}+Shift+Right" = "move right ${floatingMoveStep}";
            "${modifier}+Shift+Up"    = "move up ${floatingMoveStep}";
            "${modifier}+Shift+Down"  = "move down ${floatingMoveStep}";

            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+b"       =                         "border toggle";
            "${modifier}+Shift+b" = "[workspace=__focused__] border toggle";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+d" = "layout toggle split";

            "${modifier}+h" = "split h";
            "${modifier}+v" = "split v";

            "${modifier}+Shift+space"            = "floating toggle";
            "--whole-window ${modifier}+button2" = "floating toggle";

            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+a" = "focus parent";
            "${modifier}+z" = "focus child";

            "${modifier}+t" = "scratchpad show";
            "${modifier}+Shift+t" = "move scratchpad";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";

            "${modifier}+Ctrl+Left"  = "move workspace to output left";
            "${modifier}+Ctrl+Right" = "move workspace to output right";
            "${modifier}+Ctrl+Up"    = "move workspace to output up";
            "${modifier}+Ctrl+Down"  = "move workspace to output down";

            "${modifier}+Ctrl+${up}"    = "resize grow height 10 px or 10 ppt";
            "${modifier}+Ctrl+${down}"  = "resize shrink height 10 px or 10 ppt";
            "${modifier}+Ctrl+${right}" = "resize grow width 10 px or 10 ppt";
            "${modifier}+Ctrl+${left}"  = "resize shrink width 10 px or 10 ppt";
            "${modifier}+Ctrl+Shift+${up}"    = "resize grow height 1 px or 1 ppt";
            "${modifier}+Ctrl+Shift+${down}"  = "resize shrink height 1 px or 1 ppt";
            "${modifier}+Ctrl+Shift+${right}" = "resize grow width 1 px or 1 ppt";
            "${modifier}+Ctrl+Shift+${left}"  = "resize shrink width 1 px or 1 ppt";

            "${modifier}+c" = "exec clipman pick --tool rofi --max-items=50";

            "${modifier}+k" = "exec swaymsg reload && timeout 1.75 swaynag -t warning -e bottom -m 'reloaded sway configuration'";
            "${modifier}+Ctrl+k" = "exec swaynag -t warning -e bottom -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

            "Print" = ''exec grim -g "$(slurp)" - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';
            "Shift+Print" = ''exec grim - | swappy -f - -o "${config.xdg.userDirs.pictures}/screenshots/$(date --iso-8601=ns).png"'';

            "${modifier}+Grave" = lib.mkIf config.services.mako.enable ''exec makoctl dismiss'';
            "${modifier}+Asciitilde" = lib.mkIf config.services.mako.enable ''exec makoctl restore'';
            "${modifier}+Alt+Grave" = lib.mkIf config.services.mako.enable (
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
            "${modifier}+Scroll_Lock" = "exec swaylock";
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
            "${modifier}+Alt+Space" = "exec " + pkgs.writers.writeNu "sway-toggle-keymap" ''
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
        }

        (let
          inherit (config.wayland.windowManager.sway.config)
            modifier
            left
            right
            up
            down;

          modeGaps = "gaps: ${down}|${up} (± inner), ${left}|${right} (± outer), u|l (0 inner/outer), d (default), + Shift (global), b|B (bar)";
        in lib.mkIf cfg.enableGaps {
          gaps = {
            inner = 15;
            smartGaps = true;
            smartBorders = "on";
          };

          keybindings."${modifier}+g" = ''mode "${modeGaps}"; bar hidden_state show'';

          modes.${modeGaps} = let
            inherit (config.wayland.windowManager.sway.config.gaps) inner;
          in {
            ${left} = "gaps outer current minus 5";
            ${right} = "gaps outer current plus 5";
            ${down} = "gaps inner current minus 5";
            ${up} = "gaps inner current plus 5";
            "l" = "gaps outer current set 0";
            "u" = "gaps inner current set 0";
            "d" = "gaps outer current set 0; gaps inner current set ${toString inner}; bar bar-0 gaps 0";
            "b" = "bar bar-0 gaps 0 ${toString inner} ${toString inner} ${toString inner}";

            "Shift+${left}"  = "gaps outer all minus 5";
            "Shift+${up}"    = "gaps inner all plus 5";
            "Shift+${down}"  = "gaps inner all minus 5";
            "Shift+${right}" = "gaps outer all plus 5";
            "Shift+u" = "gaps inner all set 0";
            "Shift+l" = "gaps outer all set 0";
            "Shift+d" = "gaps outer all set 0; gaps inner all set ${toString inner}; bar bar-0 gaps 0";
            "Shift+b" = "bar bar-0 gaps 0";

            "Return" = ''mode "default"; bar hidden_state hide'';
            "Escape" = ''mode "default"; bar hidden_state hide'';
          };
        })
      ];
    };
  };
}
