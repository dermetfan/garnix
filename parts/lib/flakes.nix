lib:

{
  /*
  If the given NixOS module is a function that takes a parameter named `self`,
  pin it to the given `self`.
  This is necessary because downstream flakes may use the module like this:

      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ <this-module> <downstream-module> ];
      }

  That would replace `self` (if already set by currying) with `self` from the downstream flake
  but the downstream flake likely just wants to set `self` for its own modules.
  */
  pinModuleSelf = self: moduleSpec:
    let
      module =
        if builtins.isPath moduleSpec
        then import moduleSpec
        else moduleSpec;
      functionArgs = lib.functionArgs module;
    in
    if lib.isFunction module && functionArgs ? self
    then lib.setFunctionArgs
      (args: module (args // { inherit self; }))
      (builtins.removeAttrs functionArgs [ "self" ])
    else moduleSpec;
}
