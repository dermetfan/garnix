_:

final: prev: {
  xkeyboard_config = prev.xkeyboard_config.overrideAttrs (oldAttrs: let
    symbols = builtins.toFile "rnav" ''
      default partial
      xkb_symbols "altgr" {
          key <LatI> { [ void, void, Up,    Up    ] };
          key <LatJ> { [ void, void, Left,  Left  ] };
          key <LatK> { [ void, void, Down,  Down  ] };
          key <LatL> { [ void, void, Right, Right ] };

          key <LatU> { [ void, void, Home, Home ] };
          key <LatO> { [ void, void, End,  End  ] };
      };
    '';

    rules = builtins.toFile "rnav.part" ''
      ! option     = symbols
        rnav:altgr = +rnav(altgr)
    '';
  in {
    preBuild = oldAttrs.preBuild or "" + ''
      rules_parts_end=$'\n]\n\nrules_parts_generated = []'
      substituteInPlace ../rules/meson.build \
        --replace-fail "$rules_parts_end" $'\n    '"'rnav.part',$rules_parts_end"

      cp ${symbols} ../symbols/rnav
      cp ${rules} ../rules/rnav.part
    '';
  });
}
