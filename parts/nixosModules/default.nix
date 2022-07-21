{ lib, ... } @ args:

{
  flake.nixosModules = lib.pipe ./. [
    (lib.filesystem.importDirToAttrsWithOpts { recursive = true; doImport = true; })
    (lib.flip removeAttrs [ "default" ])
    (builtins.mapAttrs (_: part: part args))
    (modules: modules // { default.imports = builtins.attrValues modules; })
  ];
}
