self: super: {
  nixos-shell = super.fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = "2d6b3b5074417b036eba8b44e6511fbfb49c07bd";
    sha256 = "0y6bbfv7rmlm7sql8gfk0fi2q1fkf7ijwi4hshgc11pv2wb88dqb";
  };
}
