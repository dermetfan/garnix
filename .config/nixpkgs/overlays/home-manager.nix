self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "e75b68e39195bda85ccb88541b89b4d75f86631a";
    sha256 = "18rqnj0mcv42z7lmhia6vqfrj1ryywwpx077p5grxzld1mipin91";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
