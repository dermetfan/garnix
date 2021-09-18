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

  mkNode = args: mkNixos (args // {
    modules = args.modules or [] ++ [ ./node.nix ];
  });
in

{ laptop = mkNixos (import ./laptop); } //

lib.mapAttrs' (k: v: lib.nameValuePair
  ("nodes/${k}")
  (mkNode (v // {
    modules = v.modules or [] ++ [ {
      networking.hostName = k;
    } ];
  }))
) (self.outputs.lib.filesystem.importDirToAttrs ./nodes)
