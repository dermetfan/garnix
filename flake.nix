{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neuron = {
      url = "github:srid/neuron";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dermetfan-blog = {
      url = "hg+ssh://hg@hg.sr.ht/~dermetfan/dermetfan-blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }: let
    outLib = (import ./lib.nix self).outputs;
  in
    flake-utils.lib.eachDefaultSystem (system: {
      packages = outLib.packages system;

      legacyPackages = outLib.legacyPackages {
        inherit system;
        config = import nixpkgs/config.nix;
      };
    }) //
    outLib.singles //
    {
      lib = import ./lib.nix;
      nixosModules = outLib.nixosModules ./nixos;
      overlays = outLib.overlays nixpkgs/overlays // {
        dermetfan-blog = self.inputs.dermetfan-blog.overlay;
      };
    };
}
