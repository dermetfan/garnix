{ lib, ... } @ args:

{
  flake.homeManagerModules = lib.pipe ./. [
    (lib.filesystem.importDirToAttrsWithOpts { recursive = true; doImport = true; })
    (lib.flip removeAttrs [ "default" ])
    (modules: modules // { default.imports = builtins.attrValues modules; })
  ];
}
