_:

{ config, lib, ... }:

let
  cfg = config.services.yggdrasil;
in {
  options.services.yggdrasil.publicPeers.germany.enable = lib.mkEnableOption "public peers in Germany";

  # XXX fetch and parse https://github.com/yggdrasil-network/public-peers/blob/master/europe/germany.md
  config.services.yggdrasil.settings.Peers = lib.mkIf cfg.publicPeers.germany.enable [
    # Falkenstein, public node hosted on a Hetzner Online GmbH dedicated server, operated by [mkg20001](https://github.com/mkg20001)
    "tls://ygg.mkg20001.io:443"

    # Nuremberg, hosted on Netcup, operated by [Marek Küthe](https://mk16.de/)
    "quic://ygg1.mk16.de:1339?key=0000000087ee9949eeab56bd430ee8f324cad55abf3993ed9b9be63ce693e18a"

    # Nuremberg, hosted on Netcup, operated by [Marek Küthe](https://mk16.de/)
    "quic://ygg2.mk16.de:1339?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae"

    # Nuremberg, hosted on Netcup
    "tls://159.195.4.143:9001"

    # Hetzner, Nürnberg
    "tls://vpn.ltha.de:443?key=0000006149970f245e6cec43664bce203f2514b60a153e194f31e2b229a1339d"

    # Nuremberg, operated by [deb](https://ysl.su)
    "tls://yggdrasil.su:62586"

    # Nuremberg, Germany, operated by vito-box-v2
    "tls://91.98.161.68:9001?key=0e638944bfd6b277fa5e0dddbeb4444778eea8bece63a9862c661797022a8f05"

    # Frankfurt, public nodes, operated by [sergeysedoy97](https://t.me/sergeysedoy97)
    "quic://[2a0b:4142:ce0::2]:65535"
    "quic://[2a0b:4142:e9e::2]:65535"
    "quic://87.251.77.39:65535"
    "quic://[2a0c:b641:ce0::25d8:c5d6]:65535"

    # Frankfurt, VPS, 2Gbps operated by [lcharles123](https://github.com/lcharles123)
    "quic://ip6.fvm.mywire.org:443?key=000000000143db657d1d6f80b5066dd109a4cb31f7dc6cb5d56050fffb014217"

    # Frankfurt, DigitalOcean, 2Gbps, operated by [avevad](https://t.me/avevad)
    "tls://helium.avevad.com:1337"

    # Frankfurt, VPS, public node, operated by [Orbit173](https://github.com/Orbit173), 1Gbit/s
    "tls://[2a0f:b240:e:162::1]:443?key=000000035621c71b5610434589df051aed2688510f904ae79860668dc0fbf182"

    # Frankfurt, DE, axxa.dev, operated by [Adalbert Alexandru](https://axxa.dev)
    "quic://ygg-oracle.axxa.dev:18083"

    # Frankfurt, DigitalOcean, operated by vito-box
    "tls://64.226.122.118:10000"

    # Hetzner, Falkenstein, operated by neilalexander
    "tls://yggdrasil.neilalexander.dev:64648?key=ecbbcb3298e7d3b4196103333c3e839cfe47a6ca47602b94a6d596683f6bb358"

    # OVH, Limburg, dedicated server owned and operated by Liizzii
    "quic://bode.theender.net:42269"

    # Hetzner, Nuremberg, three dedicated servers operated by [SolSoCoG](https://solsocog.de)
    "tls://n.ygg.yt:443"
    "tls://b.ygg.yt:443"
    "tls://g.ygg.yt:443"

    # Frankfurt, DigitalOcean VPS, operated by [Octopixel](https://github.com/Octopixel40)
    "quic://des.8px.sk:4321"

    # Bavaria, Germany, residential / Kabel Deutschland, operated by [adingbatponder](https://codeberg.org/adingbatponder)
    "tls://reticulum.me:12393?key=a3d411280dfc350a4484aa3da5feb0407518c5820cbb011d5620347769b26665"
  ];
}
