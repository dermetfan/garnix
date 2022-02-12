self:

let
  inherit (self.inputs.nixpkgs) lib;

  mkNixos = args: lib.nixosSystem (args // {
    specialArgs = { inherit self; } // args.specialArgs or {};
    modules = args.modules or [] ++ [
      self.outputs.nixosModule
      { nixpkgs.pkgs = self.outputs.legacyPackages.${args.system}; }
    ];
  });
in

lib.mapAttrs (k: v:
  mkNixos (v // {
    modules = v.modules or [] ++ [
      { networking.hostName = k; }
      ./node.nix
    ];
  })
) (self.outputs.lib.filesystem.importDirToAttrs ./nodes)
