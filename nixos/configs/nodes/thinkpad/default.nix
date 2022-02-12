self: {
  system = "x86_64-linux";

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    ({ self, lib, ... }: {
      imports = let
        secrets = ../../../../secrets/hosts/thinkpad/secrets.nix;
      in 
        lib.optional (lib.fileContents secrets != "") secrets;

      bootstrap.secrets."secrets.nix".path = null;
    })
  ];
}
