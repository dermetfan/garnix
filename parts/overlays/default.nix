{ lib, ... } @ args:

{
  flake.overlays = lib.pipe ./. [
    (lib.filesystem.importDirToAttrsWithOpts { doImport = true; })
    (lib.flip removeAttrs [ "default" ])
    (builtins.mapAttrs (_: part: part args))
    (overlays: overlays // { default = lib.composeManyExtensions (builtins.attrValues overlays); })
  ];
}
