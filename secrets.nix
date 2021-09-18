let
  secrets = [
    "cache.sec"
    "nextcloud"
    "ssmtp"
  ];
in builtins.listToAttrs (map (secret: {
  name = "secrets/${secret}.age";
  value.publicKeys = [];
}) secrets)
