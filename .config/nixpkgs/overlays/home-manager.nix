self: super:

{
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "6aa44d62ad6526177a8c1f1babe1646c06738614";
    sha256 = "1dzga1a2jnlqzapx4lhc811akip1addx7s5gmzj6aq801gbqjx9i";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
