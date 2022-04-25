{
  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.flake-utils.follows = "flake-utils";
    };
    home-manager = {
      url = "github:dermetfan/home-manager/next";
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
      url = "hg+https://hg@hg.sr.ht/~dermetfan/dermetfan-blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fish-tide = {
      # TODO update when fixed: https://github.com/IlanCosman/tide/issues/253
      url = "github:IlanCosman/tide/v4.3.4";
      flake = false;
    };
    fish-abbreviation-tips = {
      url = "github:Gazorby/fish-abbreviation-tips";
      flake = false;
    };
    fish-autopair = {
      url = "github:jorgebucaran/autopair.fish";
      flake = false;
    };
    fish-colored-man-pages = {
      url = "github:PatrickF1/colored_man_pages.fish";
      flake = false;
    };
    kak-cosy-gruvbox = {
      url = "github:Anfid/cosy-gruvbox.kak";
      flake = false;
    };
    kak-auto-pairs = {
      url = "github:alexherbo2/auto-pairs.kak";
      flake = false;
    };
    kak-sudo-write = {
      url = "github:occivink/kakoune-sudo-write";
      flake = false;
    };
    kak-move-line = {
      url = "git+https://git@git.sr.ht/~dermetfan/move-line.kak";
      flake = false;
    };
    kak-smarttab = {
      url = "github:andreyorst/smarttab.kak";
      flake = false;
    };
    kak-surround = {
      url = "github:h-youhei/kakoune-surround";
      flake = false;
    };
    kak-wordcount = {
      url = "github:ftonneau/wordcount.kak";
      flake = false;
    };
    kak-tug = {
      url = "github:matthias-margush/tug";
      flake = false;
    };
    kak-fetch = {
      url = "github:mmlb/kak-fetch";
      flake = false;
    };
    kak-casing = {
      url = "github:Parasrah/casing.kak";
      flake = false;
    };
    kak-smart-quotes = {
      url = "github:chambln/kakoune-smart-quotes";
      flake = false;
    };
    kak-close-tag = {
      url = "github:h-youhei/kakoune-close-tag";
      flake = false;
    };
    kak-phantom-selection = {
      url = "github:occivink/kakoune-phantom-selection";
      flake = false;
    };
    kak-shellcheck = {
      url = "github:whereswaldon/shellcheck.kak";
      flake = false;
    };
    kak-change-directory = {
      url = "git+https://git@git.sr.ht/~dermetfan/change-directory.kak";
      flake = false;
    };
    kak-explain-shell = {
      url = "github:ath3/explain-shell.kak";
      flake = false;
    };
    kak-elvish = {
      url = "gitlab:SolitudeSF/elvish.kak";
      flake = false;
    };
    kak-crosshairs = {
      url = "github:insipx/kak-crosshairs";
      flake = false;
    };
    kak-table = {
      url = "github:listentolist/kakoune-table";
      flake = false;
    };
    kak-local-kakrc = {
      url = "github:dgmulf/local-kakrc";
      flake = false;
    };
    kak-expand = {
      url = "github:occivink/kakoune-expand";
      flake = false;
    };
    kak-neuron = {
      url = "github:MilanVasko/neuron-kak";
      flake = false;
    };
    kak-tmux-info = {
      url = "github:jbomanson/tmux-kak-info.kak";
      flake = false;
    };
    kak-csv = {
      url = "github:gspia/csv.kak";
      flake = false;
    };
    kak-registers = {
      url = "github:Delapouite/kakoune-registers";
      flake = false;
    };
    kak-marks = {
      url = "github:Delapouite/kakoune-marks";
      flake = false;
    };
    kak-mark = {
      url = "gitlab:fsub/kakoune-mark";
      flake = false;
    };
    kak-word-select = {
      url = "git+https://git@git.sr.ht/~dermetfan/word-select.kak";
      flake = false;
    };
    kak-interactively = {
      url = "github:chambln/kakoune-interactively";
      flake = false;
    };
    kak-palette = {
      url = "github:Delapouite/kakoune-palette";
      flake = false;
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
      overlays = builtins.mapAttrs (k: v: v self) (out.overlays nixpkgs/overlays);
      nixosModules = out.nixosModules nixos/modules;
      nixosConfigurations = import nixos/configs self;
      homeManagerModules = out.nixosModules home-manager/modules;
      homeManagerProfiles = import home-manager/profiles self;

      deploy = {
        nodes = builtins.mapAttrs (k: v: {
          profiles.system.path = deploy-rs.lib.${v.config.nixpkgs.pkgs.system}.activate.nixos v;
          sshUser = "root";
          user = "root";
          hostname = "${k}.hosts.${v.config.networking.domain}";
        }) self.outputs.nixosConfigurations;

        sshOpts = [ "-i" "secrets/deployer_ssh_ed25519_key" ];
      };

      checks = builtins.mapAttrs (system: deployLib:
        deployLib.deployChecks self.outputs.deploy
      ) deploy-rs.lib;
    };
}
