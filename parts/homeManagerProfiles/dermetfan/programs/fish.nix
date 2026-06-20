{ self, ... }:

{
  programs = {
    eza.enable = true;
    zoxide.enable = true;

    fish = {
      shellAliases = {
        diff = "diff -r --suppress-common-lines";
        watch = "watch --color";
        pv = "pv -pea";
      };

      theme = "ayu Dark";

      interactiveShellInit = ''
        set fish_greeting
      '';

      plugins = map (name: {
        inherit name;
        src = self.inputs."fish-${name}";
      }) [
        "abbreviation-tips"
        "autopair"
        # Alternative: https://github.com/decors/fish-colored-man
        # Allows configuring colors but has no command like `cless` for less uses other than man.
        "colored-man-pages"
      ];
    };
  };
}
