{ self, lib, ... }:

{
  flake.lib = import ./lib lib;

  perSystem = { pkgs, ... }: {
    checks.lib = pkgs.runCommand "tests" {
      __impure = true;
      requiredSystemFeatures = [ "recursive-nix" ];
      nativeBuildInputs = with pkgs; [ nix cacert ];
      NIX_CONFIG = ''
        extra-experimental-features = nix-command flakes
        show-trace = true
      '';
    } ''
      mkdir home
      export HOME="$PWD/home"

      cp -r ${self} src
      cd src

      result=$(nix eval .#lib.tests)
      echo "$result"

      if [[ "$result" != '[ ]' ]]; then
        exit 1
      fi

      touch $out
    '';
  };
}
