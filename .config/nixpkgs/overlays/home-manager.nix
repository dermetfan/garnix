self: super: {
  home-manager-src = super.fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "93b10bcf3cf09df990908f4ca428b18eab34aa3f";
    sha256 = "1b3yi82p20b78plx1bg5mfy45p2dfjj56l8g74nlhz19zwmk61ra";
  };

  home-manager =
    (import self.home-manager-src {
      pkgs = self;
    }).home-manager;
}
