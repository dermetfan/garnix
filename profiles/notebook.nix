{ hardware ? {}
, config, pkgs, lib }:

lib.mkMerge [
  (import ./common.nix {
    inherit hardware config pkgs;
  })

  (import ../modules/hotkeys.nix {
    inherit pkgs;
    keys = hardware.keys or {};
  })

  (import ../modules/lid.nix)

  (import ../modules/touchpad.nix {
    minSpeed = "0.825";
    maxSpeed = "2";
  })

  (import ../modules/graphical.nix {
    inherit pkgs lib;
  })

  (import ../modules/dev.nix {
    natExternalInterface = hardware.interfaces.wlan or null;
  })

  {
    nixpkgs.config.allowUnfree = true;

    networking = {
      hostName = "dermetfan";
      networkmanager.enable = true;
    };

    services.printing.enable = true;

    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
        corefonts
        dejavu_fonts
        hack-font
        ucs-fonts
        libertine
        nerdfonts
        proggyfonts
        terminus_font
        anonymousPro
        font-awesome-ttf
        fira
        fira-code
        fira-mono
      ];
    };

    hardware.pulseaudio.enable = false; # does not work with sound.mediaKeys.enable because amixer cannot connect to PulseAudio user daemon as another user (root) => share PulseAudio cookie?
  }
]
