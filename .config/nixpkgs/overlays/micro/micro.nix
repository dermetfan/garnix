{ buildGoPackage, fetchFromGitHub, ... }:

buildGoPackage rec {
  name = "micro-${version}";
  version = "1.3.1";

  goPackagePath = "github.com/zyedidia/micro";
  subPackages = [ "cmd/micro" ];

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "micro";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0kmn4qn352dak3fnkyj019ghg8aizxlq8g9r068ka8y5ahng9lx6";
  };

  goDeps = ./deps.nix;
}
