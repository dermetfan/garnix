lib:

let
  data = {
    recursion = {
      input = {
        a.a.a = 1;
        a.b.a = 2;
        a.c = 3;
      };
      cond = p: _: p != [ "a" "b" ];
      pred = _: v: !builtins.isAttrs v && v != 1;
    };
  };
in

lib.mapAttrs' (k: lib.nameValuePair "test:${k}") {
  "attrsets.mapAttrsRecursiveCondWithPath" = {
    expr = with data.recursion;
      lib.attrsets.mapAttrsRecursiveCondWithPath
        cond
        (p: v: lib.showAttrPath p + "=" + builtins.toJSON v)
        input;
    expected.a = {
      a.a = "a.a.a=1";
      b = ''a.b={"a":2}'';
      c = "a.c=3";
    };
  };

  "attrsets.findAttrsRecursiveCond" = {
    expr = with data.recursion;
      lib.attrsets.findAttrsRecursiveCond
        cond pred input;
    expected = [ [ "a" "c" ] ];
  };

  "attrsets.findFlattenAttrsRecursiveCond" = {
    expr = with data.recursion;
      lib.attrsets.findFlattenAttrsRecursiveCond
        cond pred lib.showAttrPath input;
    expected."a.c" = 3;
  };
}
