{ options, config, lib, ... }:

let
  cfg = config.age.sensible;
in {
  options.age.sensible = lib.mkEnableOption "sensible defaults" // {
    default = options ? age;
  };

  config = lib.mkIf cfg {
    age.secretsDir = lib.mkDefault "${config.xdg.configHome}/agenix";
  };
}
