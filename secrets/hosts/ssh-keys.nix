let
  findSecrets = d: let
    entries = builtins.readDir d;
    list = map (name: {
      inherit name;
      value = entries.${name};
    }) (builtins.attrNames entries);
    files = builtins.filter (x:
      x.value == "regular" &&
      (builtins.match "^(initrd_)?ssh_host_.*_key.pub$" x.name != null)
    ) list;
    dirs = builtins.filter (x: x.value == "directory") list;
    names = map (x: x.name);
    dirsResults = (map (x:
      map (y: "${x}/${y}") (findSecrets "${d}/${x}")
    ) (names dirs));
    removeDotPub = f: builtins.substring 0 (builtins.stringLength f - 4) f;
  in
    (map removeDotPub (names files)) ++
    (builtins.foldl' (a: b: a ++ b) [] dirsResults);
in

map (f: "hosts/${f}") (
  findSecrets ./.
)
