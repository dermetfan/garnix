_:

{ config, lib, ... }:

let
  cfg = config.services.yggdrasil;
in {
  options.services.yggdrasil.publicPeers.germany.enable = lib.mkEnableOption "public peers in Germany";

  config.services.yggdrasil.settings.Peers = lib.mkIf cfg.publicPeers.germany.enable [
    "tcp://94.130.203.208:5999"
    "tcp://phrl42.ydns.eu:8842"
    "tcp://ygg.mkg20001.io:80"
    "tcp://ygg.mkg20001.io:80"
    "tcp://gutsche.tech:8888"
    "tcp://ygg1.mk16.de:1337?key=0000000087ee9949eeab56bd430ee8f324cad55abf3993ed9b9be63ce693e18a"
    "tcp://ygg2.mk16.de:1337?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae"
    "tls://vpn.ltha.de:443?key=0000006149970f245e6cec43664bce203f2514b60a153e194f31e2b229a1339d"
    "tls://de-fsn-1.peer.v4.yggdrasil.chaz6.com:4444"
    "tcp://yggdrasil.su:62486"
    "tls://x-fra-promo.sergeysedoy97.ru:65535"
    "tls://87.251.77.39:65535"
  ];
}
