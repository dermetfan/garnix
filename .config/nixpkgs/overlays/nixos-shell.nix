self: super: {
  nixos-shell = super.fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = "39936f8b60c6ff3644ae508af38505d39f97730c";
    sha256 = "11aj2ck9kh4iaiidrsf8kxp6rqpghi0zw88hncmv5r37wcby7ika";
  };
}
