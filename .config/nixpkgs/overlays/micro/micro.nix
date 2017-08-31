{ buildGoPackage, fetchFromGitHub, writeText, ... }:

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

  patches = [
    (writeText "ldflags.patch" ''
      diff --git a/cmd/micro/micro.go b/cmd/micro/micro.go
      index 483d74e..1d981d5 100644
      --- a/cmd/micro/micro.go
      +++ b/cmd/micro/micro.go
      @@ -44,8 +44,8 @@ var (

       	// Version is the version number or commit hash
       	// These variables should be set by the linker when compiling
      -	Version     = "0.0.0-unknown"
      -	CommitHash  = "Unknown"
      +	Version     = "${version}"
      +	CommitHash  = "${src.rev}"
       	CompileDate = "Unknown"

       	// L is the lua state
    '')
  ];
}
