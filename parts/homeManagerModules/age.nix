{ options, config, lib, ... }:

let
  cfg = config.age.sensible;
in {
  options.age.sensible = lib.mkEnableOption "sensible defaults" // {
    default = true;
  };

  config = lib.mkIf cfg (
    # `mkIf` still checks that all options exist before resolving its condition
    # so we need to eagerly check for the existance of the age option.
    # This is needed to avoid errors when the agenix module is not imported.
    lib.optionalAttrs (options ? age.secretsDir) {
      age.secretsDir = lib.mkDefault "${config.xdg.configHome}/agenix";
    }
  );
}
