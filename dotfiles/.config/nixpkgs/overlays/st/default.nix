self: super: {
  st = with super; assert st ? version && st.version  == "0.7" || st.name == "st-0.7"; st.override {
    patches = let
      select = custom: default:
        if builtins.pathExists custom
        then custom else default;
    in [
      (select ./st-alpha-0.7.diff (fetchpatch {
        url = https://st.suckless.org/patches/alpha/st-alpha-0.7.diff;
        sha256 = "e89ef927e902f7bf679362ccfda3f03caca92540ebefaf56da24241993c5f30f";
      }))

      (fetchpatch {
        url = https://st.suckless.org/patches/clipboard/st-clipboard-0.7.diff;
        sha256 = "1fgzppdzv28pmp88rnlsspx9axlkn2m20yw3b9w429cbd1kqw9fy";
      })
    ];
  };
}
