{ nixosConfig, config, lib, ... }:

let
  cfg = config.misc.data;
in {
  options.misc.data = with lib; {
    enable = mkOption {
      type = types.bool;
      default = nixosConfig.misc.data.enable or false;
      description = "Configure other modules to save on user's data partition.";
    };

    path = mkOption {
      type = types.path;
      default = nixosConfig.misc.data.mountPoint +
        (lib.optionalString nixosConfig.misc.data.userFileSystems "/${config.home.username}");
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      userDirs = let
        inherit (config.home) homeDirectory username;
      in {
        desktop = homeDirectory;
        download = "${homeDirectory}/downloads";
        templates = homeDirectory;
        publicShare = homeDirectory;
        documents = "/data/${username}/documents";
        music = "/data/${username}/audio/music";
        pictures = "/data/${username}/images";
        videos = "/data/${username}/videos";
      };

      configFile."gtk-3.0/bookmarks".text = ''
        file:///${cfg.path}
      '';
    };

    config.programs.i3status-rust.data = {
      enable = true;
      inherit (cfg) path;
    };
  };
}
