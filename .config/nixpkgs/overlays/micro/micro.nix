{ buildGoPackage, fetchFromGitHub, writeText, ... }:

buildGoPackage rec {
  name = "micro-${version}";
  version = "1.3.2-dev";

  goPackagePath = "github.com/zyedidia/micro";
  subPackages = [ "cmd/micro" ];

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "micro";
    rev = "0c1db1e813fd1c157df8180a9687f9f002c206da";
    fetchSubmodules = true;
    sha256 = "16f200hlp44b3dsii8i8y7v52lr7h9sr99j710mp6s95sl5lskjw";
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
