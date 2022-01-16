final: prev: {
  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall}
      ln -s ${prev.flake.inputs.kak-cosy-gruvbox}/colors/cosy-gruvbox.kak $out/share/kak/colors/
    '';
  });

  kakounePlugins = prev.kakounePlugins // builtins.listToAttrs (
    map (name: prev.lib.nameValuePair name (
      prev.kakouneUtils.buildKakounePluginFrom2Nix rec {
        pname = name;
        version = src.rev;
        src = prev.flake.inputs."kak-${name}";
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
    ]
  );
}
