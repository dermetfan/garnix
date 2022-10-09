lib:

rec {
  /*
   Like `mapAttrsRecursiveCond` from nixpkgs
   but the condition and mapping functions
   take the attribute path as their first parameter.
   */
  mapAttrsRecursiveCondWithPath = cond: f: let
    recurse = path:
      builtins.mapAttrs (
        name: value: let
          newPath = path ++ [name];
          g =
            if builtins.isAttrs value && cond newPath value
            then recurse
            else f;
        in
          g newPath value
      );
  in
    recurse [];

  /*
   Returns the paths to values that satisfy the given predicate in the given attrset.
   The predicate and recursion predicate functions take path and value as their parameters.
   If the recursion prediate function is null, it defaults to the negated predicate.
   */
  findAttrsRecursiveCond = cond: pred: attrs:
    lib.collect builtins.isList (
      mapAttrsRecursiveCondWithPath
      (
        if cond == null
        then p: v: !pred p v
        else cond
      )
      (
        p: v:
          if pred p v
          then p
          else null
      )
      attrs
    );

  findAttrsRecursive = findAttrsRecursiveCond null;

  # Returns a new attrset from the result of `findAttrsRecursiveCond` using the given naming function.
  findFlattenAttrsRecursiveCond = cond: pred: mkName: attrs:
    builtins.listToAttrs (
      map
      (
        path:
          lib.nameValuePair
          (mkName path)
          (lib.getAttrFromPath path attrs)
      )
      (findAttrsRecursiveCond cond pred attrs)
    );
}
