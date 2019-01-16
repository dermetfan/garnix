self: super: {
  nixos-shell = super.fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = "7678921a8f7f274757b9991757f822ad9217495d";
    sha256 = "0654d5bvq9kzycf79x6rcmgx5wwk3xpmmlcjn6ab5ppdnf52q01r";
  };
}
