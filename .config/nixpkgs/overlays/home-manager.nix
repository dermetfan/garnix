self: super: {
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "6eea2a409e56d23f1e3f703afb3aa0527d1cc8e7";
    sha256 = "14774fnmy9a6ybb4072q88zz7wrbgmp01rnwg4chl4mhvy7vnwyy";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
