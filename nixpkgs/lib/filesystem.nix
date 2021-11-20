self:

let
  inherit (self.inputs.nixpkgs) lib;
in

rec {
  importDirToListWithOpts = { path, recursive ? false }:
    lib.pipe path [
      builtins.readDir
      (lib.mapAttrsToList (k: v:
        if lib.hasSuffix ".nix" k || (
          v == "directory" &&
          builtins.pathExists "${toString path}/${k}/default.nix"
        )
        then lib.nameValuePair
          (
            if v == "directory" then k else
              lib.removeSuffix ".nix" k
          )
          (import "${toString path}/${k}")
        else lib.optional recursive (map
          (x: x // { name = "${k}/${x.name}"; })
          (importDirToListWithOpts {
            path = "${toString path}/${k}";
            recursive = true;
          })
        )
      ))
      lib.flatten
    ];

  importDirToList = path:
    importDirToListWithOpts { inherit path; };

  importDirToListRecursive = path:
    importDirToListWithOpts { inherit path; recursive = true; };

  importDirToAttrs = path:
    builtins.listToAttrs (importDirToList path);

  importDirToAttrsRecursive = path:
    builtins.listToAttrs (importDirToListRecursive path);
}
