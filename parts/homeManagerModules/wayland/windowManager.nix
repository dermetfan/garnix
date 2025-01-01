{
  # TODO remove once using a recent enough home-manager version
  # https://github.com/nix-community/home-manager/issues/2064#issuecomment-1049757267
  systemd.user.targets.tray.Unit = {
    Description = "Home Manager System Tray";
    Requires = [ "graphical-session-pre.target" ];
  };
}
