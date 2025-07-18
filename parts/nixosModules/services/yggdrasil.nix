_:

{ config, lib, ... }:

let
  cfg = config.services.yggdrasil;
in {
  options.services.yggdrasil.publicPeers.germany.enable = lib.mkEnableOption "public peers in Germany";

  # XXX fetch and parse https://github.com/yggdrasil-network/public-peers/blob/master/europe/germany.md
  config.services.yggdrasil.settings.Peers = lib.mkIf cfg.publicPeers.germany.enable [
    # Falkenstein, public node hosted on a Hetzner Online GmbH dedicated server, operated by mkg20001
    tls://ygg.mkg20001.io:443

    # Nuremberg, hosted on Netcup, operated by Marek Küthe
    tls://ygg1.mk16.de:1338?key=0000000087ee9949eeab56bd430ee8f324cad55abf3993ed9b9be63ce693e18a

    # Nuremberg, hosted on Netcup, operated by Marek Küthe
    tls://ygg2.mk16.de:1338?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae

    # Hetzner, Nürnberg
    tls://vpn.ltha.de:443?key=0000006149970f245e6cec43664bce203f2514b60a153e194f31e2b229a1339d

    # Hetzner, Falkenstein, operated by Chaz6
    tls://de-fsn-1.peer.v4.yggdrasil.chaz6.com:4444

    # Nuremberg, operated by deb
    tls://yggdrasil.su:62586

    # Nuremberg, operated by mlupo, 600Mbit/s down, 300Mbit/s up
    tls://mlupo.duckdns.org:9001

    # Frankfurt, public node, operated by sergeysedoy97, 100 Mbit/s, IPv4 only
    tls://s-fra-0.sergeysedoy97.ru:65534 # Dual-Stack by Cloudflare Spectrum

    # Frankfurt, VPS, 2Gbps operated by lcharles123
    quic://ip4.fvm.mywire.org:443?key=000000000143db657d1d6f80b5066dd109a4cb31f7dc6cb5d56050fffb014217
    quic://ip6.fvm.mywire.org:443?key=000000000143db657d1d6f80b5066dd109a4cb31f7dc6cb5d56050fffb014217

    # Frankfurt, DigitalOcean, 2Gbps, operated by avevad
    tls://helium.avevad.com:1337

    # Hetzner, Falkenstein, operated by neilalexander
    tls://yggdrasil.neilalexander.dev:64648?key=ecbbcb3298e7d3b4196103333c3e839cfe47a6ca47602b94a6d596683f6bb358

    # OVH, Limburg, dedicated server owned and operated by Liizzii
    quic://bode.theender.net:42269

    # Hetzner, Nuremberg, three dedicated servers operated by SolSoCoG
    tls://n.ygg.yt:443
    tls://b.ygg.yt:443
    tls://g.ygg.yt:443
  ];
}
