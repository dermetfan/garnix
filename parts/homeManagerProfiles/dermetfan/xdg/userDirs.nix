{ config, ... }:

{
  xdg.userDirs = {
    download  = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/documents";
    music     = "${config.home.homeDirectory}/media/audio/music";
    pictures  = "${config.home.homeDirectory}/media/images";
    videos    = "${config.home.homeDirectory}/media/videos";
  };
}
