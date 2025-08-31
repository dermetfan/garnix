{
  programs.foot = {
    server.enable = true;

    settings = {
      mouse.hide-when-typing = true;
      mouse-bindings = {
        font-increase = "none";
        font-decrease = "none";
      };
    };
  };

  # workaround for https://codeberg.org/dnkl/foot/issues/1844
  # TODO upstream into home-manager?
  systemd.user.services.foot.Service.PassEnvironment = [ "PATH" ];
}
