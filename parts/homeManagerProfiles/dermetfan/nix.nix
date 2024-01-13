{ self, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.nix;
in {
  imports = [
    { key = "age"; imports = [ self.inputs.agenix.homeManagerModules.default ]; }
  ];

  options.profiles.dermetfan.nix.enable = lib.mkEnableOption "nix" // {
    default = true;
  };

  config = {
    age.secrets.nix-access-tokens.file = ../../../secrets/users/dermetfan/nix-access-tokens.age;

    nix.extraOptions = ''
      !include ${config.age.secrets.nix-access-tokens.path}
    '';
  };
}
