lib:

rec {
  /*
  Like `filterAttrs` for values of a module evaluation.

  The predicate function receives the path to the value,
  its option declaration and the resolved value itself.
  */
  filterOptionValues = let
    recurse = p: pred: options: values:
      if !__isAttrs values || lib.isDerivation values
      then values
      else
        __mapAttrs
        (
          k:
            recurse
            (p ++ [k])
            pred
            (
              let
                o = options.${k} or null;
              in
                if lib.isOption o
                then o.type.getSubOptions []
                else o
            )
        )
        (
          lib.filterAttrs
          (k: pred (p ++ [k]) options.${k} or null)
          values
        );
  in
    recurse [];

  retainModuleArgs = old: new:
    if lib.isFunction old && lib.isFunction new
    then lib.setFunctionArgs new (lib.functionArgs old)
    else new;

  mapModuleBody = f: module:
    retainModuleArgs module (args:
      f args (
        if lib.isFunction module
        then module args
        else module
      )
    );

  withEnableOption = path:
    mapModuleBody (args: body:
      let
        options = body.options or {};
        config = removeAttrs (body.config or body) [ "imports" ];
      in
      lib.optionalAttrs (body ? imports) {
        inherit (body) imports;
      } // {
        options = lib.recursiveUpdate
          (lib.setAttrByPath path {
            enable = lib.mkEnableOption (lib.last path) // (
              let enablePath = path ++ [ "enable" ]; in
              lib.optionalAttrs
                (lib.hasAttrByPath   enablePath options)
                (lib.getAttrFromPath enablePath options)
            );
          })
          options;

        config = lib.mkIf (
          lib.getAttrFromPath
            ([ "config" ] ++ path ++ [ "enable" ])
            args
        ) config;
      }
    );

  enableByDefault = path:
    mapModuleBody (args:
      lib.flip lib.recursiveUpdate (
        lib.setAttrByPath ([ "options" ] ++ path ++ [ "enable" "default" ]) true
      )
    );
}
