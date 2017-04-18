{ pkgs, lib }:

lib.mkMerge [
  (import ../modules/gtk.nix {
    inherit pkgs;
  })

  {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      xflux
      xorg.xrandr
      xorg.xkill
      xscreensaver
      xclip
      xsel
      libnotify
    ];

    services.xserver = {
      enable = true;

      displayManager.sessionCommands = let
        xhost = "${pkgs.xorg.xhost}/bin/xhost";
        xmodmap = "${pkgs.xorg.xmodmap}/bin/xmodmap";
      in ''
        ${xhost} local:root # allow root to connect to X server for key bindings
        ${xmodmap} -e "keycode 66 = Caps_Lock"
        xset r rate 225 27
        xset m 2
        compton -bfD 2
        devmon &
        xscreensaver -no-splash &
        syndaemon -d -i 0.625 -K -R
      '';

      displayManager.slim.defaultUser = "dermetfan";
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
      desktopManager.xterm.enable = false;
    };
  }
]
