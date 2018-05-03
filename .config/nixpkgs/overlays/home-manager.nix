self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "f26cc3b957ef77374f8b5275c1fc62217d13c6e3";
    sha256 = "0pn0xrq0gn402zwd3qq2adaay22p7dbx64lbxigvirn286sdzjjs";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
