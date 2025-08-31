_:

final: prev: {
  # TODO remove once fixed: https://github.com/NixOS/nixpkgs/issues/230580
  fishPlugins.foreign-env = prev.fishPlugins.foreign-env.overrideAttrs (oldAttrs: {
    preInstall = oldAttrs.preInstall + ''
      sed -e "s|'env'|${prev.coreutils}/bin/env|" -i functions/*
    '';
  });
}
