{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.default;
in {
  options.profiles.default.enable = lib.mkEnableOption "default settings";

  config = lib.mkIf cfg.enable {
    defaults.enable = true;

    profiles.users.enable = true;

    time.timeZone = "Europe/Berlin";

    security.acme.email = "serverkorken@gmail.com";

    programs = {
      mosh.enable = true;
      tmux.enable = true;
    };

    services = {
      openssh.enable = true;
      "1.1.1.1".enable = true;
      znapzend.enable = builtins.any (x: x == "zfs") (map
        (fs: fs.fsType)
        (builtins.attrValues config.fileSystems)
      );
    };
  };
}
