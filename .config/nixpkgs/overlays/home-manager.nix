self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "cacb8d410ec8e0e5ff08ac7aa81cd10e8e3f2eb6";
    sha256 = "17sg5hn010820nd8wphdsh3fbbgynaz74kzly51bh1gcgfi97nc1";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
