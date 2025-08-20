{ inputs, ... }:

final: prev: {
  tmuxPlugins =
    removeAttrs prev.tmuxPlugins [
      "mkDerivation" # deprecated
    ]  // builtins.listToAttrs (
      map (plugin:
        let
          args =
            prev.lib.optionalAttrs (builtins.isAttrs plugin) plugin
            // rec {
              pluginName = plugin.pluginName or plugin;
              version = src.rev;
              src = inputs."tmux-${pluginName}";
            };
        in
          prev.lib.nameValuePair
          args.pluginName
          (prev.tmuxPlugins.mkTmuxPlugin args)
      ) [
        # {
        #   # TODO https://github.com/NixOS/nixpkgs/pull/296174
        #   pluginName = "window-name";
        #   rtpFilePath = "tmux_window_name.tmux";
        #   buildInputs = with prev; [
        #     python3
        #     python3Packages.libtmux
        #   ];
        # }
        rec {
          pluginName = "kak-copy-mode";
          rtpFilePath = "bin/tmux-${pluginName}";
        }
      ]
    );
}
