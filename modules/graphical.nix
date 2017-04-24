{ pkgs, lib }:

lib.mkMerge [
  (import ../modules/gtk.nix {
    inherit pkgs;
  })

  {
    services.xserver = {
      enable = true;
      displayManager.slim.defaultUser = "dermetfan";
      desktopManager.xterm.enable = false;
    };
  }
]
