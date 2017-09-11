{ buildGoPackage, fetchFromGitHub, writeText, ... }:

buildGoPackage rec {
  name = "micro-${version}";
  version = "1.3.2-dev";

  goPackagePath = "github.com/zyedidia/micro";
  subPackages = [ "cmd/micro" ];

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "micro";
    rev = "c31613b2c77973e29512291dc64223b3731406ea";
    fetchSubmodules = true;
    sha256 = "0wpsll0sgvv56j6kj05y6dkjvfnqazs64afjfp61izqgh0l0hkhh";
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
