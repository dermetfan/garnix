{ lib, ... } @ args:

let
  overlays = lib.pipe ./. [
    (lib.filesystem.importDirToAttrsWithOpts { doImport = true; })
    (builtins.mapAttrs (_: part: part args))
    (lib.flip removeAttrs [ "default" ])
  ];
in {
  flake.overlays = overlays // {
    default = lib.composeManyExtensions (builtins.attrValues overlays);
    small = lib.composeManyExtensions (builtins.attrValues (removeAttrs overlays [
      "xkeyboard-config" # mass rebuild
    ]));
  };
}
