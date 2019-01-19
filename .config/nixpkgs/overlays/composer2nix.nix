self: super: {
  composer2nix = let
    src = super.fetchFromGitHub {
      owner = "svanderburg";
      repo = "composer2nix";
      rev = "2fb157acaf0ecbe34436195c694637396f7258a6";
      sha256 = "1xa4qrknzz74fxqqihh7san56sq2wiy39n282zrid8zm4y2yl4s6";
    };
  in (import "${src}/release.nix" {
    nixpkgs = super.path;
    systems = [ builtins.currentSystem ];
  }).package.${builtins.currentSystem};
}
