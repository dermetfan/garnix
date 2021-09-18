{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    lib = import nixpkgs/lib self;
    out = (lib.flake self).outputs;
  in
    flake-utils.lib.eachDefaultSystem (system: {
      packages = out.packages system;

      legacyPackages = out.legacyPackages {
        inherit system;
        config = import nixpkgs/config.nix;
      };
    }) //
    out.singles //
    {
      inherit lib;
      overlays = out.overlays nixpkgs/overlays // {
        dermetfan-blog = self.inputs.dermetfan-blog.overlay;
      };
      nixosModules = out.nixosModules nixos/modules;
      nixosConfigurations = import nixos/configs self;
    };
}
