{ buildGoPackage, fetchFromGitHub, writeText, ... }:

buildGoPackage rec {
  name = "micro-${version}";
  version = "1.4.1";

  goPackagePath = "github.com/zyedidia/micro";
  subPackages = [ "cmd/micro" ];

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "micro";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0m9p6smb5grdazsgr3m1x4rry9ihhlgl9ildhvfp53czrifbx0m5";
  };

  patches = [
    (writeText "ldflags.patch" ''
      diff --git a/cmd/micro/micro.go b/cmd/micro/micro.go
      index dc35ed2..25e7a56 100644
      --- a/cmd/micro/micro.go
      +++ b/cmd/micro/micro.go
      @@ -46,7 +46,7 @@ var (
       	// Version is the version number or commit hash
       	// These variables should be set by the linker when compiling
      -	Version = "0.0.0-unknown"
      +	Version = "${version}"
       	// CommitHash is the commit this version was built on
      -	CommitHash = "Unknown"
      +	CommitHash = "${src.rev}"
       	// CompileDate is the date this binary was compiled on
       	CompileDate = "Unknown"
    '')
  ];
}
