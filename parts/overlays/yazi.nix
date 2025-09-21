{ inputs, ... }:

final: prev: {
  yaziPlugins = prev.yaziPlugins // builtins.listToAttrs (
    map (name: prev.lib.nameValuePair name (
      prev.yaziPlugins.mkYaziPlugin rec {
        pname = "${name}.yazi";
        version = src.rev or inputs.yazi-plugins.rev;
        src = inputs."yazi-${name}" or (inputs.yazi-plugins // {
          # `mkYaziPlugin` checks for the owner and,
          # if it is "yazi-rs", assumes that this is
          # the yazi-plugins repository, for which it
          # behaves a bit differently to make the build work.
          owner = "yazi-rs";
        });
      }
    )) [
      "githead"
      "office"
      "zoom"
    ]
  );
}
