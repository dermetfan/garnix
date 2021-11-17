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

      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        SSH_ASKPASS_REQUIRE = "prefer";
        SSH_ASKPASS = "secrets/askpass";
        shellHook = let
          git-hooks.pre-commit = nixpkgs.legacyPackages.${system}.writers.writeDash "pre-commit" (
            nixpkgs.lib.pipe self.nixosConfigurations [
              builtins.attrValues
              (map (nixos: nixos.config.bootstrap.secrets))
              (map builtins.attrValues)
              nixpkgs.lib.flatten
              (builtins.filter ({ path, ... }: path == null))
              (map ({ file, ... }: file))
              nixpkgs.lib.unique
              nixpkgs.lib.escapeShellArgs
              (files: ''
                cd $(git rev-parse --show-toplevel)
                for file in ${files}; do
                    if test -n "$(git diff --cached --name-only -- "$file")"; then
                        >&2 printf '%s '  'You have a bootstrap secret'\'''s cleartext in the index!'
                        >&2 printf '%s\n' 'Run this command from the repo root to unstage it:'
                        >&2 printf '\t%s\n' 'git reset -- '"$file"
                        exit 1
                    fi
                done
              '')
            ]
          );
        in ''
          cd $(git rev-parse --show-toplevel)

          if [[ ! -x "$SSH_ASKPASS" ]]; then
              >&2 echo    "$SSH_ASKPASS"' is missing or not executable.'
              >&2 echo    'Please place a script there that prints the key for'
              >&2 echo -e '\tsecrets/deployer_ssh_ed25519_key'
          fi

          for hook in ${nixpkgs.lib.concatStrings (builtins.attrValues git-hooks)}; do
              ln -sf $hook .git/hooks/$(stripHash $hook)
          done
        '';
      };
    }) //
    out.singles //
    {
      inherit lib;
      overlays = out.overlays nixpkgs/overlays;
      nixosModules = out.nixosModules nixos/modules;
      nixosConfigurations = import nixos/configs self;

      deploy = {
        nodes = builtins.mapAttrs (k: v: {
          profiles.system.path = deploy-rs.lib.${v.config.nixpkgs.pkgs.system}.activate.nixos v;
          sshUser = "root";
          user = "root";
          hostname = "${k}.hosts.${v.config.networking.domain}";
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
