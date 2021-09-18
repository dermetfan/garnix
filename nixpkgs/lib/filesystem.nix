self:

{
  importDirToAttrs = path:
    with self.inputs.nixpkgs.lib;
    mapAttrs'
      (k: v: nameValuePair
        (
          if v == "directory" then k else
            removeSuffix ".nix" k
        )
        (import "${toString path}/${k}")
      )
      (filterAttrs
        (k: v: hasSuffix ".nix" k || (
          v == "directory" &&
          builtins.pathExists "${toString path}/${k}/default.nix"
        ))
        (builtins.readDir path)
      );
}
