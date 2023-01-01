_:

{ config, lib, ... }:

let
  cfg = config.services.yggdrasil;
in {
  options.services.yggdrasil.publicPeers.germany.enable = lib.mkEnableOption "public peers in Germany";

  config.services.yggdrasil.settings.Peers = lib.mkIf cfg.publicPeers.germany.enable [
    "tcp://94.130.203.208:5999"
    "tcp://bunkertreff.ddns.net:5454"
    "tcp://phrl42.ydns.eu:8842"
    "tcp://ygg.mkg20001.io:80"
    "tcp://yugudorashiru.de:80"
  ];
}
