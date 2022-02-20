self:

let
  inherit (self.inputs.nixpkgs) lib;
in

rec {
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
