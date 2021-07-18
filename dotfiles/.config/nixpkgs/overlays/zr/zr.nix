{ stdenv, rustPlatform
, fetchFromGitHub
, pkgconfig, openssl, zlib, curl, perl, cmake, ... }:

with rustPlatform;

buildRustPackage rec {
  name = "zr-${version}";
  version = "0.6.1";

  nativeBuildInputs = [
    cmake
    pkgconfig
    openssl
    zlib
    curl
    perl
  ];

  src = fetchFromGitHub {
    owner = "jedahan";
    repo = "zr";
    rev = version;
    sha256 = "1gk3aym5d4rpayrzwmq7sg5zl8527dxrw9iwky6wsw4l28v6306g";
  };

  cargoSha256 = "0gva911n4ssv5a2lf4kkyzkkbarasmhlprykkqj02xjc3ivnhzqm";
}
