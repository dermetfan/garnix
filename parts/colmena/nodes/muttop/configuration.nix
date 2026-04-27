{ inputs, ... } @ parts:

{ nodes, config, pkgs, lib, ... }:

{
  imports = [
    { key = "age"; imports = [ inputs.agenix.nixosModules.age ]; }
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "25.05";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "brscan4"
    "brscan4-etc-files"
    "brother-udev-rule-type1"
  ];

  deployment.keys.ssh_host_key.destDir = lib.mkForce (config.environment.persistence."/state".persistentStoragePath + "/etc/ssh");

  environment.persistence."/state" = {
    files = map (key: key.path) config.services.openssh.hostKeys;
    directories = [
      "/var/lib/nixos"
    ];
  };

  # https://github.com/ryantm/agenix/issues/45
  age.identityPaths = map (key: "/state${toString key.path}") config.services.openssh.hostKeys;

  profiles = {
    handson.enable = true;
    notebook.enable = true;
    gui.enable = true;
    users.enable = true;
    yggdrasil.enable = true;

    stylix.enable = false;
  };

  i18n.defaultLocale = "de_DE.UTF-8";

  console.font = "Lat2-Terminus16";

  time.timeZone = "Europe/Berlin";

  services = {
    yggdrasil.publicPeers.germany.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    displayManager = {
      enable = true;
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
      };
    };

    desktopManager.plasma6.enable = true;
    tlp.enable = false; # conflicts with power-profiles-daemon at eval time, which plasma6 enables by default

    xserver.xkb = {
      layout = lib.mkForce "de";
      variant = lib.mkForce "";
      options = lib.mkForce "";
    };

    blueman.enable = true;

    znapzend = {
      enable = true;
      zetup = let
        planFew = "1week=>1day,1month=>1week";
        planMany = "1week=>1day,1hour=>15minutes,15minutes=>5minutes,1day=>1hour,1year=>1month,1month=>1week";
      in lib.mapAttrs (k: v: {
        timestampFormat = "%Y-%m-%dT%H:%M:%SZ";
        recursive = true;
      } // v) {
        "root/root".plan = planFew;
        "root/home".plan = planMany;
      };
    };

    printing = {
      enable = true;
      stateless = true;
    };
  };

  systemd.services.ensure-printers.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10";
  };

  home-manager.users.mutmetfan = { nixosConfig, config, ... }: let
    webdav = {
      name = "Sohn-Server";
      url = "[${nodes.node-3.config.profiles.yggdrasil.ip}]/home/mutmetfan";
    };
  in {
    imports = [
      parts.config.flake.homeManagerProfiles.defaults
      ({ config, ... }: {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

        xdg = lib.mkIf config.xdg.autostart.enable {
          # Conflicts with home-manager's `xdg.autostart` at build time.
          # TODO fix upstream?
          # https://github.com/nix-community/plasma-manager/blob/27dfa61b64d0cdb8e4ba6f3aaa4d4e067d64cb5c/modules/startup.nix#L210
          configFile."autostart/plasma-manager-autostart.desktop".enable = false;

          autostart.entries = [
            # Unfortunately causes infinite recursion.
            # config.xdg.configFile."autostart/plasma-manager-autostart.desktop".source
            (builtins.toFile "plasma-manager-autostart.desktop" ''
              [Desktop Entry]
              Type=Application
              Name=Plasma Manager theme application
              Exec=${config.xdg.dataHome}/plasma-manager/run_all.sh
              X-KDE-autostart-condition=ksmserver
            '')
          ];
        };
      })
    ];

    home = {
      stateVersion = "25.05";

      username = nixosConfig.users.users.mutmetfan.name;
      homeDirectory = nixosConfig.users.users.mutmetfan.home;

      sessionVariables.EDITOR = "geany";

      packages = with pkgs; [
        libreoffice
        liberation_ttf_v2
        simple-scan
        qalculate-gtk
      ];
    };

    programs = let
      mozillaSearch = {
        default = "ecosia";
        engines = {
          ecosia.metaData = {};
          google.metaData = {};
        };
        order = [ "ecosia" "google" ];
        force = true;
      };

      nativeMessagingHosts = with pkgs; [
        kdePackages.plasma-browser-integration
      ];
    in {
      geany.enable = true;
      less.enable = true;
      fish.enable = true;

      chromium = {
        inherit nativeMessagingHosts;
        enable = true;
      };

      firefox = {
        inherit nativeMessagingHosts;

        enable = true;
        languagePacks = [ "de" ];

        profiles.${config.home.username} = {
          search = mozillaSearch;
          extensions.packages = let
            inherit (pkgs.extend inputs.nur.overlays.default) nur;
          in with nur.repos.rycee.firefox-addons; [
            plasma-integration
            ublock-origin
            decentraleyes
          ];
          settings."widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };

      thunderbird = {
        enable = true;
        profiles.${config.home.username} = {
          isDefault = true;
          search = mozillaSearch;
        };
      };

      plasma = {
        enable = true;

        kwin = {
          nightLight = {
            enable = true;
            mode = "location";
            location = {
              inherit (nixosConfig.passthru.coords) latitude longitude;
            };
            temperature.night = 3000;
          };

          effects = {
            shakeCursor.enable = true;
            wobblyWindows.enable = true;
            zoom.enable = true;
          };
        };

        kscreenlocker.timeout = 20;

        panels = [
          {
            location = "left";
            floating = true;
            widgets = [
              {
                kickoff = {
                  icon = "alienarena";
                  favoritesDisplayMode = "list";
                };
              }
              {
                iconTasks = {
                  appearance = {
                    fill = true;
                    showTooltips = false;
                  };
                  behavior.grouping = {
                    method = "byProgramName";
                    clickAction = "showTextualList";
                  };
                };
              }
              "org.kde.plasma.marginsseparator"
              { systemTray = {}; }
              { digitalClock = {}; }
              "org.kde.plasma.showdesktop"
            ];
          }
        ];

        desktop.widgets = builtins.attrValues (let
          display = {
            width = 1920;
            height = 1080;
          };
        in rec {
          notes = {
            name = "org.kde.plasma.notes";
            position = {
              horizontal = display.width - notes.size.width;
              vertical = display.height - notes.size.height;
            };
            size = with display; {
              width = width / 6;
              height = height / 4;
            };
            config.General.color = "yellow";
          };

          calculator = {
            name = "org.kde.plasma.calculator";
            position = {
              horizontal = display.width - notes.size.width - calculator.size.width;
              vertical = display.height - calculator.size.height;
            };
            size = with display; {
              width = width / 7;
              height = height / 4;
            };
          };
        });

        shortcuts.kwin = {
          view_actual_size = [ "Ctrl+Num+0" "Meta+0" ];
          view_zoom_in = [ "Ctrl+Num++" "Meta++" ];
          view_zoom_out = [ "Ctrl+Num+-" "Meta+-" ];
        };

        session.sessionRestore = {
          restoreOpenApplicationsOnLogin = "onLastLogout";
          excludeApplications = [
            "firefox"
            "chromium"
          ];
        };

        configFile = {
          kwinrc = {
            # https://github.com/nix-community/plasma-manager/issues/486
            Effect-overview.BorderActivate.value = 3;

            Windows.ElectricBorders.value = 1;

            TabBox.OrderMinimizedMode.value = 1;
          };

          dolphinrc = {
            General = {
              BrowseThroughArchives.value = true;
              ShowToolTips.value = true;
              ShowZoomSlider.value = true;
            };

            MainWindow.MenuBar.value = "Disabled";
          };

          krdpserverrc.General = {
            Autostart = true;
            Certificate = "${config.xdg.dataHome}/krdpserver/krdp.crt";
            CertificateKey = "${config.xdg.dataHome}/krdpserver/krdp.key";
            Users = config.home.username;
          };
        };
      };
    };

    gtk = {
      enable = true;
      gtk3.bookmarks = [
        (with webdav; "dav://${url} ${name}")
      ];
    };

    xdg = {
      autostart = {
        enable = true;
        readOnly = true;
        entries = [
          "${config.programs.thunderbird.package.desktopItem}/share/applications/thunderbird.desktop"
        ];
      };

      configFile."libreoffice/4/user/registrymodifications.xcu".text = let
        item = path: prop: value: let
          renderValue = value: {
            bool = builtins.toJSON;
            string = lib.id;
            list = lib.concatMapStrings (it: "<it>${renderValue it}</it>");
          }.${builtins.typeOf value} value;
        in ''
          <item oor:path="${path}">
            <prop oor:name="${prop}" oor:op="fuse">
              <value>${renderValue value}</value>
            </prop>
          </item>
        '';
      in lib.concatStrings [
        ''
          <?xml version="1.0" encoding="UTF-8"?>
          <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        ''

        # Disable file locking because it does not work properly on a WebDAV share.
        # When opened via Dolphin, it opens files in read-only mode,
        # and when mounted via davfs2 it seems to straight up not save changes,
        # probably because it saves the changes somewhere else and fails to replace the file.
        # Maybe that would work better if we configured `use_locks = 0` for davfs2
        # but Dolphin is preferred as it works better knowing the underlying filesystem is remote.
        (item "/org.openoffice.Office.Common/Misc" "UseDocumentSystemFileLocking" false)

        (item "/org.openoffice.Office.Common/Misc" "FilePickerLastService" "http://${webdav.url}/")
        (item "/org.openoffice.Office.Common/Misc" "FilePickerPlacesNames" [ webdav.name ])
        (item "/org.openoffice.Office.Common/Misc" "FilePickerPlacesUrls" [ "http://${webdav.url}/" ])

        # Use the built-in file saving dialog.
        # The system one (whichever that actually is)
        # does show the GTK3 bookmarks, but does not actually support WebDAV
        # (seems like an additional plugin needs to be installed or something).
        (item "/org.openoffice.Office.Common/Misc" "UseSystemFileDialog" false)

        ''
          </oor:items>
        ''
      ];

      dataFile = {
        "user-places.xbel" = {
          source = pkgs.replaceVars xdg-data/user-places.xbel {
            webdav = "webdav://${webdav.url}";
          };
          force = true;
        };

        "dolphinui.rc" = {
          source = xdg-data/kxmlgui5/dolphin/dolphinui.rc;
          force = true;
        };
      } // (let
        destination = "/share/remoteview";
      in {
        "remoteview/${webdav.name}.desktop".source = (pkgs.makeDesktopItem {
          inherit destination;
          inherit (webdav) name;
          desktopName = webdav.name;
          icon = "folder-remote";
          type = "Link";
          url = "webdav://${webdav.url}";
        }) + "${destination}/${webdav.name}.desktop";
      });
    };
  };

  users.users = {
    root.hashedPassword = lib.mkForce "$6$u9W4NZj2wPlDR.Vm$MC7J11xhII9DDfZ10Ev5Tna6jZX57KwKNiqiLOqR630kJsHNgpOaulFMsxQsFLfF9DUw.AsL/DnTcEYGwVO8q.";

    mutmetfan = {
      isNormalUser = true;

      hashedPassword = "$6$8Vd1aOeNzVstrZ5d$dqkCqDfj6J0wr7R0BphQBr8KdO.mJHpqpLDTsq4FNNxGNRreYCzofiQnmN1noPyvIxuvQRBcQwPP1oUMygwqv/";

      extraGroups = [
        "wheel"
        "networkmanager"
        "video" # backlight
        "lp" # printing
        "scanner"
      ];
    };
  };

  networking = {
    hostId = "8425e349";

    firewall.extraCommands = ''
      # krdpserver (KDE's built-in RDP server)
      ip6tables \
        -I INPUT \
        -p tcp \
        -s ${nodes.laptop.config.profiles.yggdrasil.ip} \
        -d ${config.profiles.yggdrasil.ip} \
        --dport 3389 \
        -j ACCEPT
    '';
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r root/root@blank
  '';
}
