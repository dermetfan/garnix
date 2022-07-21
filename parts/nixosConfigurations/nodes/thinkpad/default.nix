parts:

{
  system = "x86_64-linux";

  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (parts: { lib, ... }: {
      imports = let
        secrets = "${toString <secrets>}/hosts/thinkpad/secrets.nix";
      in 
        lib.optional (lib.fileContents secrets != "") secrets;

      bootstrap.secrets."secrets.nix".path = null;
    })
  ];
}
