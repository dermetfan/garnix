{ stdenv, buildGoPackage, fetchFromGitHub
, ncurses }:

buildGoPackage rec {
  name = "mkinfo-unstable-${version}";
  version = "2017-06-05";

  goPackagePath = "github.com/zyedidia/mkinfo";

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "mkinfo";
    rev = "v1.0";
    sha256 = "1zv11s0w2mjycda1msixlsaplbqrm49b1v89g568hwm66gjag2bv";
  };

  patches = [ ./ldflags.patch ];

  goDeps = ./deps.nix;

  buildInputs = [ ncurses ];
}
