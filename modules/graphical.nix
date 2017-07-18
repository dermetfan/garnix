{ ... }:

{
  services.xserver = {
    enable = true;
    displayManager.slim.defaultUser = "dermetfan";
    desktopManager.xterm.enable = false;
  };
}
