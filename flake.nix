{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-shell = {
      url = "sourcehut:~dermetfan/home-manager-shell/release-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        home-manager.follows = "home-manager";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    wrapper-manager.url = "github:viperML/wrapper-manager";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jaillm = {
      url = "github:myme/jaillm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        disko.follows = "disko";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      url = "github:oraios/serena/v1.5.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.follows = "nur";
      };
    };
    gruvbox-wallpapers = {
      url = "github:vctrblck/gruvbox-wallpapers";
      flake = false;
    };
    dermetfan-blog = {
      url = "sourcehut:~dermetfan/dermetfan-blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty/v1.19.7";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    optnix = {
      url = "github:water-sucks/optnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-bwrap = {
      url = "github:michalrus/opencode-bwrap-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdg-desktop-portal-termfilepickers = {
      url = "github:Guekka/xdg-desktop-portal-termfilepickers";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
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
    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-kak-copy-mode = {
      url = "github:jbomanson/tmux-kak-copy-mode";
      flake = false;
    };
    tmux-window-name = {
      url = "github:ofirgall/tmux-window-name";
      flake = false;
    };
    kak-cosy-gruvbox = {
      url = "github:Anfid/cosy-gruvbox.kak";
      flake = false;
    };
    kak-themes = {
      url = "github:anhsirk0/kakoune-themes";
      flake = false;
    };
    kak-render-markdown = {
      url = "github:kmafeni04/render-markdown.kak";
      flake = false;
    };
    kak-sudo-write = {
      url = "github:occivink/kakoune-sudo-write";
      flake = false;
    };
    kak-move-lines = {
      url = "git+https://codeberg.org/raiguard/kak-move-lines";
      flake = false;
    };
    kak-peneira = {
      url = "github:gustavo-hms/peneira";
      flake = false;
    };
    kak-luar = { # dependency of peneira
      url = "github:gustavo-hms/luar";
      flake = false;
    };
    kak-mru-files = { # optional dependency of peneira
      url = "gitlab:kstr0k/mru-files.kak";
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
    kak-case = {
      url = "gitlab:FlyingWombat/case.kak";
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
    kak-nu = {
      url = "github:deeuu/nu.kak";
      flake = false;
    };
    kak-beancount = {
      url = "github:enricozb/beancount.kak";
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
    kak-tmux-info = {
      url = "github:jbomanson/tmux-kak-info.kak";
      flake = false;
    };
    kak-registers = {
      url = "github:Delapouite/kakoune-registers";
      flake = false;
    };
    kak-mark = {
      url = "gitlab:fsub/kakoune-mark";
      flake = false;
    };
    kak-hump = {
      url = "github:Delapouite/kakoune-hump";
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
    kak-focus = {
      url = "github:caksoylar/kakoune-focus";
      flake = false;
    };
    kak-quickscope = {
      url = "sourcehut:~voroskoi/quickscope.kak";
      flake = false;
    };
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    yazi-githead = {
      url = "github:llanosrocas/githead.yazi";
      flake = false;
    };
    yazi-office = {
      url = "github:macydnah/office.yazi";
      flake = false;
    };
  };

  outputs = inputs @ { nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs.lib = nixpkgs.lib.extend (final: prev:
        nixpkgs.lib.recursiveUpdate prev (import parts/lib prev)
      );
    } {
      systems = [ "x86_64-linux" ];

      imports = map (part: ./parts + "/${part}") [
        # module args
        "nixpkgs.nix"

        # schema outputs
        "legacyPackages.nix"
        "packages.nix"
        "devShells.nix"
        "overlays"
        "apps.nix"
        "nixosModules"
        "nixosConfigurations.nix"

        # third-party schema outputs
        "homeManagerModules"
        "homeManagerProfiles"
        "colmena"

        # custom outputs
        "lib.nix"
      ];
    };

  nixConfig = {
    extra-substituters = [ "https://colmena.cachix.org" ];
    extra-trusted-public-keys = [ "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" ];
  };
}
