self:

let
  inherit (self.inputs.nixpkgs) lib;
in

flake: # `self` of the user flake

rec {
  outputs = {
    singles = {
      # wrap to avoid infinite recursion
      inherit (
        let inherit (flake) outputs; in
        lib.optionalAttrs (outputs ? nixosModules)
          { nixosModule.imports = builtins.attrValues outputs.nixosModules; } //
        lib.optionalAttrs (outputs ? homeManagerModules)
          { homeManagerModule.imports = builtins.attrValues outputs.homeManagerModules; } //
        lib.optionalAttrs (outputs ? overlays) {
            overlay = final: prev: # wrap to name arguments for flake check
              (lib.composeManyExtensions (builtins.attrValues outputs.overlays)) final prev;
        }
      ) nixosModule homeManagerModule overlay;
    };

    packages = system: outputs.singles.overlay {}
      (import flake.inputs.nixpkgs { inherit system; });

    legacyPackages = args:
      import flake.inputs.nixpkgs ({
        overlays = lib.optional
          (outputs.singles ? overlay)
          outputs.singles.overlay;
      } // args);

    nixosModules = lib.flip lib.pipe [
      self.outputs.lib.filesystem.importDirToAttrsRecursive
      (lib.mapAttrs (k: fixNixosModuleSelf))
    ];

    overlays = self.outputs.lib.filesystem.importDirToAttrs;
  };

  fixNixosModuleSelf = moduleSpec:
    /*
    If a function arg named `self` exists ensure it is this flake's `self`.
    This is necessary because downstream flakes may use the module like this:

        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit self; };
          modules = [ <this-module> <downstream-module> ];
        }

    That would replace `self` in this flake's module with `self` from the downstream flake
    even though the downstream flake likely just wants to set `self` for its own modules.
    */
    let
      module =
        if (builtins.isPath moduleSpec)
        then import moduleSpec
        else moduleSpec;
      functionArgs = builtins.functionArgs module;
    in
    if builtins.isFunction module && functionArgs ? self
    then lib.setFunctionArgs
      (args: module (args // { self = flake; }))
      (builtins.removeAttrs functionArgs [ "self" ])
    else moduleSpec;
}
