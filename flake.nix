{
  inputs = {
    nixpkgs-unstable.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
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

  outputs = { self, nixpkgs, flake-utils, deploy-rs, ... }: let
    lib = import nixpkgs/lib self;
    out = (lib.flake self).outputs;
  in
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: {
      packages = out.packages system;

      legacyPackages = out.legacyPackages {
        inherit system;
        config = import nixpkgs/config.nix;
      };

      defaultApp = self.outputs.apps.${system}.deploy-rs;
      apps = nixpkgs.lib.genAttrs [ "deploy-rs" "agenix" ] (flake:
        self.inputs.${flake}.defaultApp.${system}
      );
    }) //
    out.singles //
    {
      inherit lib;
      overlays = out.overlays nixpkgs/overlays // {
        dermetfan-blog = self.inputs.dermetfan-blog.overlay;
      };
      nixosModules = out.nixosModules nixos/modules;
      nixosConfigurations = import nixos/configs self;

      deploy = {
        nodes = builtins.mapAttrs (k: v: {
          profiles.system.path = deploy-rs.lib.${v.config.nixpkgs.pkgs.system}.activate.nixos v;
          sshUser = "root";
          user = "root";
          hostname =
            if nixpkgs.lib.hasPrefix "node-" k
            then "${nixpkgs.lib.removePrefix "node-" k}.nodes.${v.config.networking.domain}"
            else ""; # use --hostname
        }) self.outputs.nixosConfigurations;

        sshOpts = [
          "-i" "secrets/deployer_ssh_ed25519_key"

          # May be needed for password authentication to work.
          # see https://github.com/serokell/deploy-rs/issues/78#issuecomment-802402464
          # "-t"
        ];
      };

      checks = builtins.mapAttrs (system: deployLib:
        deployLib.deployChecks self.outputs.deploy
      ) deploy-rs.lib;
    };
}
