self:

let
  inherit (self.inputs.nixpkgs) lib;
in 

rec {
  outputs = {
    singles = {
      # wrap to avoid infinite recursion
      inherit (
        let inherit (self) outputs; in
        lib.optionalAttrs (outputs ? nixosModules)
          { nixosModule.imports = builtins.attrValues outputs.nixosModules; } //
        lib.optionalAttrs (outputs ? overlays)
          { overlay = lib.composeManyExtensions (builtins.attrValues outputs.overlays); }
      ) nixosModule overlay;
    };

    packages = system: outputs.singles.overlay {}
      (import self.inputs.nixpkgs { inherit system; });

    legacyPackages = args:
      import self.inputs.nixpkgs ({
        overlays = lib.optional
          (outputs.singles ? overlay)
          outputs.singles.overlay;
      } // args);

    nixosModules = modulesPath:
      lib.listToAttrs (map
        (path: lib.nameValuePair
          (lib.pipe path [
            toString
            (lib.removePrefix ((toString modulesPath) + "/"))
            (lib.removeSuffix ".nix")
          ])
          (fixNixosModuleSelf path)
        )
        (lib.filesystem.listFilesRecursive modulesPath)
      );

    overlays = overlaysPath:
      lib.mapAttrs'
        (k: v: lib.nameValuePair
          (
            if v == "directory" then k else
              lib.removeSuffix ".nix" k
          )
          (import "${toString overlaysPath}/${k}")
        )
        (lib.filterAttrs
          (k: v: lib.hasSuffix ".nix" k || (
            v == "directory" &&
            builtins.pathExists "${toString overlaysPath}/${k}/default.nix"
          ))
          (builtins.readDir overlaysPath)
        );
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
      (args: module (args // { inherit self; }))
      (builtins.removeAttrs functionArgs [ "self" ])
    else moduleSpec;
}
