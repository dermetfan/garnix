{ config, lib, ... }:

let
  cfg = config.profiles.iog;
in {
  options.profiles.iog.enable = lib.mkEnableOption "IOG";

  config = lib.mkIf cfg.enable {
    nix = {
      binaryCachePublicKeys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "midnight-testnet-0:DSKrPCP3Ls8wGLvKyBiZB2P8ysMcSNqJRhqGJC+F7wY="
      ];

      extraOptions = ''
        trusted-substituters = https://hydra.iohk.io https://hydra.p42.at
      '';
    };
  };
}
