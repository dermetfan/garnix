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
    '';
  });

  kakounePlugins = prev.kakounePlugins // builtins.listToAttrs (
    map (name: prev.lib.nameValuePair name (
      prev.kakouneUtils.buildKakounePluginFrom2Nix rec {
        pname = name;
        version = src.rev;
        src = inputs."kak-${name}";
      }
    )) [
      "auto-pairs"
      "sudo-write"
      "move-line"
      "smarttab"
      "surround"
      "wordcount"
      "tug"
      "fetch"
      "casing"
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
      "marks"
      "mark"
      "word-select"
      "interactively"
      "palette"
      "focus"
    ]
  );
}
