{ self, inputs, ... }:

{ options, config, lib, pkgs, ... }:

let
  cfg = config.profiles.dev;
in {
  imports = [
    inputs.optnix.nixosModules.optnix
  ];

  options.profiles.dev.enable = lib.mkEnableOption "dev settings";

  config = lib.mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        internalInterfaces = [
          "ve-+" # nixos-containers
        ];
        # externalInterface has to be set in user's config
      };

      networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };

    environment.systemPackages = with pkgs; [
      man-pages
    ];

    documentation = {
      dev.enable = true;
      man.generateCaches = true;
    };

    programs.optnix = {
      enable = true;
      settings = rec {
        default_scope = "nixos";
        # https://water-sucks.github.io/optnix/recipes/nixos.html#optnix-module-examples
        scopes.${default_scope} = {
          description = "NixOS: ${config.networking.hostName}";
          options-list-file = (inputs.optnix.mkLib pkgs).mkOptionsList { inherit options; };
          evaluator = "nix eval ${self}#nixosConfigurations.${config.networking.hostName}.config.{{ .Option }}";
        };
      };
    };

    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
  };
}
