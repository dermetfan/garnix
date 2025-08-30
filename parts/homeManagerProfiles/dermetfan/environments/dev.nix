{ self, nixosConfig ? null, options, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.environments.dev;
in {
  options.profiles.dermetfan.environments.dev = with lib; {
    enable.default = false;
    enableNative = mkEnableOption "native development programs";
    enableRust = mkEnableOption "Rust development programs";
    enableWeb = mkEnableOption "web development programs";
  };

  imports = [
    self.inputs.nix-index-database.hmModules.nix-index
    self.inputs.optnix.homeModules.optnix
  ];

  config = {
    programs = {
      man = {
        enable = true;
        generateCaches = true;
      };

      atuin.enable = true;

      mercurial.enable = true;
      git.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      skim.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      geany.enable = config.profiles.dermetfan.environments.gui.enable;

      cargo.enable = cfg.enableRust;

      nix-index-database.comma.enable = true;

      optnix = {
        enable = true;
        settings = rec {
          default_scope = "home-manager";
          scopes.${default_scope} = {
            description = "home-manager: ${config.home.username}";
            # https://water-sucks.github.io/optnix/recipes/home-manager.html#standaloneinside-home-manager-module
            options-list-file = (self.inputs.optnix.mkLib pkgs).mkOptionsList {
              # The agenix module fails to evaluate.
              options = removeAttrs options [ "age" ];
              transform = o: o // {
                name = lib.removePrefix "home-manager.users.${config.home.username}." o.name;
              };
            };
          } // lib.optionalAttrs (nixosConfig != null) {
            evaluator = "nix eval ${self}#nixosConfigurations.${nixosConfig.networking.hostName}.config.home-manager.users.${config.home.username}.{{ .Option }}";
          };
        };
      };
    };

    home.packages = with pkgs;
      [
        man-pages
        ack
        grex
        nox
        nixos-shell
        pijul
        qemu
        dos2unix
        hyperfine
        entr
        watchexec
        jnv
        jd-diff-patch
        yq
        zig-shell-completions
      ] ++
      lib.optionals stdenv.isLinux [
        tty-share
        upterm
        mdcat
      ] ++
      lib.optionals config.profiles.dermetfan.environments.gui.enable [
        # aqemu
        meld
        # pgadmin
        sqlitebrowser
      ] ++
      lib.optionals cfg.enableNative [
        lldb
        valgrind
        qcachegrind
      ] ++
      lib.optionals cfg.enableWeb (
        [ httpie curlie ] ++
        lib.optionals pkgs.stdenv.isLinux [
          httping
        ]
      )
    ;
  };
}
