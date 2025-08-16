{ inputs, ... }:

final: prev: {
  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall}

      for f in ${with inputs; prev.lib.escapeShellArgs [
        kak-cosy-gruvbox
        kak-themes
      ]}; do
        ln -s "$f"/colors/* $out/share/kak/colors/
      done

      ln -s ${prev.lib.escapeShellArg inputs.kak-gruvbox-soft}/gruvbox-soft.kak $out/share/kak/colors/
    '';
  });

  kakounePlugins =
    removeAttrs prev.kakounePlugins (
      builtins.attrNames (
        prev.lib.importJSON
        "${inputs.nixpkgs}/pkgs/applications/editors/kakoune/plugins/deprecated.json"
      )
    ) // builtins.listToAttrs (
      map (name: prev.lib.nameValuePair name (
        prev.kakouneUtils.buildKakounePluginFrom2Nix rec {
          pname = name;
          version = src.rev;
          src = inputs."kak-${name}";
        }
      )) [
        "easymotion"
        "sudo-write"
        "move-line"
        "smarttab"
        "surround"
        "wordcount"
        "tug"
        "fetch"
        "case"
        "smart-quotes"
        "close-tag"
        "phantom-selection"
        "shellcheck"
        "change-directory"
        "explain-shell"
        "elvish"
        "crosshairs"
        "table"
        "local-kakrc"
        "expand"
        "neuron"
        "tmux-info" # dependency of tmux-kak-copy-mode
        "csv"
        "registers"
        "mark"
        "hump"
        "interactively"
        "palette"
        "focus"
      ]
    );
}
