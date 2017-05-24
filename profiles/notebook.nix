{ config, pkgs, lib }:

lib.mkMerge [
  (import ./common.nix {
    inherit config pkgs lib;
  })

  (import ../modules/data.nix {
    inherit config pkgs lib;
  })

  (import ../modules/hotkeys.nix {
    inherit config pkgs;
  })

  (import ../modules/lid.nix)

  (import ../modules/touchpad.nix {
    inherit config;
  })

  (import ../modules/graphical.nix {
    inherit pkgs lib;
  })

  (import ../modules/dev.nix {
    inherit config;
  })

  {
    passthru.settings.touchpad = {
      minSpeed = "0.825";
      maxSpeed = "2";
    };

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
