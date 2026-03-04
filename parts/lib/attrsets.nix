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
   The recursion condition and predicate functions take path and value as their parameters.
   */
  findAttrsRecursiveCond' = cond: pred: attrs:
    lib.flatten (
      lib.collect builtins.isList (
        mapAttrsRecursiveCondWithPath
        cond
        (
          path: value:
            if pred path value
            then lib.singleton {inherit path value;}
            else null
        )
        attrs
      )
    );

  # Like `findAttrsRecursiveCond` but returns only the paths, not the values.
  findAttrsRecursiveCond = cond: pred: attrs:
    map
    ({path, ...}: path)
    (findAttrsRecursiveCond' cond pred attrs);

  # Like `findAttrsRecursiveCond'` using the negated predicate as recursion condition.
  findAttrsRecursive' = pred:
    findAttrsRecursiveCond'
    (p: v: !pred p v)
    pred;

  # Like `findAttrsRecursiveCond` using the negated predicate as recursion condition.
  findAttrsRecursive = pred:
    findAttrsRecursiveCond
    (p: v: !pred p v)
    pred;

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

  attrsToListRecursiveCond = cond: attrs:
    let
      inner = prefix: attrs:
        if builtins.isAttrs attrs && cond prefix attrs
        then
            lib.mapAttrsToList
            (
              name: value: let
                path = prefix ++ lib.singleton name;
              in inner path value
            )
            attrs
        else {
          path = prefix;
          value = attrs;
        };
    in
      lib.flatten (inner [] attrs);

  attrsToListRecursive = attrsToListRecursiveCond (_: _: true);

  recursiveListToAttrs = list:
    lib.fold lib.recursiveUpdate {} (
      map
      ({path, value}: lib.setAttrByPath path value)
      list
    );

  /*
   Like `filterAttrs` from nixpkgs
   but the predicate function takes the attribute path
   as the first parameter.
   */
  filterAttrsRecursiveCond' = cond: pred: attrs:
    recursiveListToAttrs (
      builtins.filter
      (
        {
          path,
          value,
        }:
          pred path value
      )
      (attrsToListRecursiveCond cond attrs)
    );

  filterAttrsRecursive' = pred: filterAttrsRecursiveCond' pred pred;

  removeAttrsByPath = attrs: paths:
    filterAttrsRecursiveCond'
    (path: _: lib.any (lib.lists.hasPrefix path) paths)
    (path: _: !builtins.elem path paths)
    attrs;
}
