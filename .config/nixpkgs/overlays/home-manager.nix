self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "3160c0384370f7a8dc340cf341c67066daf9c81e";
    sha256 = "0i94vxd35k0dzsjpi4qv64264rqyax7jfx1f685apn2ac192apq2";
  };

  home-manager = import self.home-manager-src {
    pkgs = self;
    modulesPath = "${self.home-manager-src}/modules";
  };
}

