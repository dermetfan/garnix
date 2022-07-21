_:

{ config, lib, ... }:

let
  cfg = config.services.yggdrasil;
in {
  options.services.yggdrasil = with lib; {
    # The yggdrasil module shipped with NixOS
    # does not allow its `config` to be merged
    # because it declares it with type `attrs`.
    # TODO fix upstream
    mergeableConfig = mkOption {
      type = with types; submodule {
        freeformType = attrsOf (oneOf [
          (attrsOf (listOf str))
          (listOf str)
          attrs
          str
        ]);
      };
      default = {};
    };

    publicPeers.germany.enable = mkEnableOption "public peers in Germany";
  };

  config.services.yggdrasil = {
    config = lib.mkIf (cfg.mergeableConfig != {}) cfg.mergeableConfig;

    mergeableConfig.Peers = lib.optionals cfg.publicPeers.germany.enable [
      "tcp://94.130.203.208:5999"
      "tcp://bunkertreff.ddns.net:5454"
      "tcp://phrl42.ydns.eu:8842"
      "tcp://ygg.mkg20001.io:80"
      "tcp://yugudorashiru.de:80"
    ];
  };
}
