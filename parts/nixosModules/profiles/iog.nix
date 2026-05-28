_:

{ config, lib, ... }:

let
  cfg = config.profiles.iog;
in {
  options.profiles.iog.enable = lib.mkEnableOption "IOG";

  config = lib.mkIf cfg.enable {
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    nix.settings = {
      extra-substituters = [ "https://cache.iog.io" ];
      extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    };
  };
}

