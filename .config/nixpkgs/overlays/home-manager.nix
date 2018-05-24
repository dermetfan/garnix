self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "dfaccdd03b083bb36ac78ff5e9ec01e8d2335efc";
    sha256 = "08xlkq2f9rwwzpmhpfs1n2q8jw5k7lrvc7mnmpxykrshngd2zig7";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
