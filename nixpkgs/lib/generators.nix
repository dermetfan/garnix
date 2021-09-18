self:

{
  # XXX rewrite with lib.generators.toKeyValue?
  # XXX is escapeShellArg really ok for PHP strings?
  toPHP = {
    variable ? null,
  }: attrs:
    with self.inputs.nixpkgs.lib;
    let
      writeValue = value:
        if isString value then escapeShellArg value else
        if isInt value || isFloat value then toString value else
        if isBool value then if value then "true" else "false" else
        if isList value then "[\n" + (concatStringsSep ",\n" (map writeValue value)) + "\n]" else
        if isAttrs value then "[\n" + (concatStringsSep ",\n" (mapAttrsToList (k: v: "${escapeShellArg k} => ${writeValue v}") value)) + "\n]" else
        throw "value of unsupported type ${builtins.typeOf value}"
      ;
    in
      if variable == null
      then writeValue attrs
      else concatStringsSep "\n" (
        mapAttrsToList
          (k: v: "${k} = ${v};")
          (mapAttrs'
            (k: v: nameValuePair
              "\$${variable}[${escapeShellArg k}]"
              (writeValue v)
            )
            attrs
          )
      );
}
