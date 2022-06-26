{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
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
      url = "github:dermetfan/home-manager/broot-config-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-shell = {
      url = "sourcehut:~dermetfan/home-manager-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        home-manager.follows = "home-manager";
      };
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
      url = "sourcehut:~dermetfan/move-line.kak";
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
      url = "sourcehut:~dermetfan/casing.kak";
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
      url = "sourcehut:~dermetfan/change-directory.kak";
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
      url = "sourcehut:~dermetfan/word-select.kak";
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

  outputs = { self, nixpkgs, flake-utils, deploy-rs, home-manager, home-manager-shell, ... }: let
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
      ) // {
        home-manager-shell = flake-utils.lib.mkApp {
          drv = home-manager-shell.lib {
            inherit system;
            target = self;
            args.extraSpecialArgs.nixosConfig = null;
          };
        };

        default = self.outputs.apps.${system}.deploy-rs;
      };

      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        SSH_ASKPASS_REQUIRE = "prefer";
        SSH_ASKPASS = "secrets/askpass";
        shellHook = ''
          cd $(git rev-parse --show-toplevel)

          if [[ ! -x "$SSH_ASKPASS" ]]; then
              >&2 echo    "$SSH_ASKPASS"' is missing or not executable.'
              >&2 echo    'Please place a script there that prints the key for'
              >&2 echo -e '\tsecrets/deployer_ssh_ed25519_key'
          fi

          export NIX_PATH="''${NIX_PATH:-}''${NIX_PATH:+:}secrets=$PWD/secrets"
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
