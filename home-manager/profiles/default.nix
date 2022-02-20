self:

let
  inherit (builtins) mapAttrs attrValues readDir;
  inherit (self.inputs.nixpkgs) lib;
  inherit (self.outputs.lib.modules) mapModuleBody enableByDefault withEnableOption;

  profiles = lib.pipe ./. [
    (self.outputs.lib.flake self).outputs.nixosModules
    (lib.filterAttrs (k: v: k != "default")) # ignore this file
    (mapAttrs (k: enableByDefaultUnlessDefined ([ "profiles" ] ++ lib.splitString "/" k)))
  ];

  collectionProfiles = lib.pipe ./. [
    readDir
    (lib.filterAttrs (k: v: v == "directory"))
    (mapAttrs (name: v: {
      imports = attrValues (
        lib.filterAttrs
          (k: v: lib.hasPrefix "${name}/" k)
          profiles
      );
    }))
    (mapAttrs (k: enableByDefaultUnlessDefined [ "profiles" k ]))
  ];

  enableByDefaultUnlessDefined = path: module:
    mapModuleBody (args: body:
      (
        let next = withEnableOption path module; in
        if lib.hasAttrByPath ([ "options" ] ++ path ++ [ "enable" ]) body
        then next
        else enableByDefault path next
      ) args
    ) module;

  addHomeManagerModulesImport = module:
    { imports = [ module ../imports/module.nix ]; };
in

mapAttrs
  (k: addHomeManagerModulesImport)
  (profiles // collectionProfiles)
