_:

final: prev: {
  xkeyboard_config = prev.xkeyboard_config.overrideAttrs (oldAttrs: let
    types = builtins.toFile "starfighter" ''
      default partial
      xkb_types "basic" {
          // XXX This reacts to Super_R and Shift_R as well.
          // Ideally it would only react to Super_L and Shift_L.

          // Like ALPHABETIC plus Level4 on Mod4
          type "STARFIGHTER_ALPHABETIC_FN_MOD4" {
              modifiers= Shift+Lock+Mod4;
              map[None]= Level1;
              map[Shift]= Level2;
              map[Lock]= Level2;
              map[Mod4]= Level4;
              level_name[Level1]= "Base";
              level_name[Level2]= "Caps";
              level_name[Level4]= "Fn";
          };

          // Like ALPHABETIC plus Level4 on Shift+Mod4
          type "STARFIGHTER_ALPHABETIC_FN_SHIFT_MOD4" {
              modifiers= Shift+Lock+Mod4;
              map[None]= Level1;
              map[Shift]= Level2;
              map[Lock]= Level2;
              map[Shift+Mod4]= Level4;
              level_name[Level1]= "Base";
              level_name[Level2]= "Caps";
              level_name[Level4]= "Fn";
          };
      };
    '';

    symbols = builtins.toFile "starfighter" ''
      default partial
      xkb_symbols "basic" {
          // Fn+F4 sends Super_L+LatP/AD10
          key <LatP> {
              type= "STARFIGHTER_ALPHABETIC_FN_MOD4",
              [ void, void, void, XF86_Display ]
          };

          // Fn+F12 sends Super_L+Shift_L+LatS/AC02
          key <LatS> {
              type= "STARFIGHTER_ALPHABETIC_FN_SHIFT_MOD4",
              [ void, void, void, XF86_SelectiveScreenshot ]
          };
      };
    '';

    rules = builtins.toFile "starfighter.part" ''
      ! option      = types
        starfighter = +starfighter

      ! option      = symbols
        starfighter = +starfighter
    '';
  in {
    preBuild = oldAttrs.preBuild or "" + ''
      rules_parts_end=$'\n]\n\nrules_parts_generated = []'
      substituteInPlace ../rules/meson.build \
        --replace-fail "$rules_parts_end" $'\n    '"'starfighter.part',$rules_parts_end"

      cp ${types} ../types/starfighter
      cp ${symbols} ../symbols/starfighter
      cp ${rules} ../rules/starfighter.part
    '';
  });
}
