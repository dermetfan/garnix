let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);

  pkgs = import (with lock.nodes.nixpkgs.locked; builtins.fetchGit {
    url = "https://github.com/${owner}/${repo}";
    inherit rev;
  }) { system = builtins.currentSystem; };

  compat = import (
    pkgs.fetchFromGitHub {
      owner = "edolstra";
      repo = "flake-compat";
      rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
      hash = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
    }
  ) {
    src = ./.;
    inherit (pkgs) system;
  };
in

if pkgs.lib.inNixShell
then compat.shellNix
else compat.defaultNix
