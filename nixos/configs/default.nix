self:

let
  inherit (self.inputs) nixpkgs;
in

nixpkgs.lib.mapAttrs (k: v:
  let args = v self; in
  (args.nixpkgs or nixpkgs).lib.nixosSystem (builtins.removeAttrs args [ "nixpkgs" ] // {
    specialArgs = { inherit self; } // args.specialArgs or {};
    modules = args.modules or [] ++ [
      self.outputs.nixosModule
      { nixpkgs.pkgs = self.outputs.legacyPackages.${args.system}; }
      { networking.hostName = k; }
      ./node.nix
    ];
  })
) (self.outputs.lib.filesystem.importDirToAttrs ./nodes)
