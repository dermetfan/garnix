{ buildGoPackage, fetchFromGitHub, writeText, ... }:

buildGoPackage rec {
  name = "micro-${version}";
  version = "1.3.4";

  goPackagePath = "github.com/zyedidia/micro";
  subPackages = [ "cmd/micro" ];

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "micro";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "1giyp2xk2rb6vdyfnj5wa7qb9fwbcmmwm16wdlnmq7xnp7qamdkw";
  };

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
