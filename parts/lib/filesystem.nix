lib:

rec {
  importDirToListWithOpts = { recursive ? false, doImport ? false }: path:
    lib.pipe path [
      builtins.readDir
      (lib.mapAttrsToList (k: v:
        if
          v != "directory" && lib.hasSuffix ".nix" k ||
          v == "directory" && builtins.pathExists "${toString path}/${k}/default.nix"
        then lib.nameValuePair
          (
            if v == "directory" then k else
              lib.removeSuffix ".nix" k
          )
          (
            let p = "${toString path}/${k}"; in
            if doImport then import p else p
          )
        else lib.optional recursive (map
          (x: x // { name = "${k}/${x.name}"; })
          (
            importDirToListWithOpts
              { inherit recursive doImport; }
              "${toString path}/${k}"
          )
        )
      ))
      lib.flatten
    ];

  importDirToList =
    importDirToListWithOpts {};

  importDirToListRecursive =
    importDirToListWithOpts { recursive = true; };

  importDirToAttrsWithOpts = opts: path:
    builtins.listToAttrs (importDirToListWithOpts opts path);

  importDirToAttrs =
    importDirToAttrsWithOpts {};

  importDirToAttrsRecursive =
    importDirToAttrsWithOpts { recursive = true; };
}
