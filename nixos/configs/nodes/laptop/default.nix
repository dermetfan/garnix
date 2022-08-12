self: {
  system = "x86_64-linux"; # XXX use localSystem instead? see `man configuration.nix` for `nixpkgs.pkgs`

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    ({ self, lib, ... }: {
      imports = let
        secrets = "${toString <secrets>}/hosts/laptop/secrets.nix";
      in 
        lib.optional (lib.fileContents secrets != "") secrets;

      bootstrap.secrets."secrets.nix".path = null;
    })
  ];
}
