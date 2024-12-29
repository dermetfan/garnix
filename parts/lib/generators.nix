lib:

{
  # XXX rewrite with lib.generators.toKeyValue?
  toPHP = {
    variable ? null,
  }: attrs:
    with lib;
    let
      # XXX does this implementation cover all cases?
      escapePHPString = arg: "'${replaceStrings ["'"] ["'\\''"] (toString arg)}'";
      writeValue = value:
        if isString value then escapePHPString value else
        if isInt value || isFloat value then toString value else
        if isBool value then if value then "true" else "false" else
        if isList value then "[\n" + (concatStringsSep ",\n" (map writeValue value)) + "\n]" else
        if isAttrs value then "[\n" + (concatStringsSep ",\n" (mapAttrsToList (k: v: "${escapePHPString k} => ${writeValue v}") value)) + "\n]" else
        if isPath value then ''substr(file_get_contents(${escapePHPString value}), 0, -1)'' else
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
              "\$${variable}[${escapePHPString k}]"
              (writeValue v)
            )
            attrs
          )
      );
}
