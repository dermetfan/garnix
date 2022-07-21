{ self, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; }) # tide
    any-nix-shell
  ];

  programs = {
    exa.enable = true;
    zoxide.enable = true;

    fish = {
      shellAliases = {
        diff = "diff -r --suppress-common-lines";
        watch = "watch --color";
        pv = "pv -pea";
      };

      functions._tide_item_any_nix_shell = ''
        set_color --bold green
        echo \ (nix-shell-info)
      '';

      theme = "ayu Dark";

      shellInit = ''
        any-nix-shell fish | source
      '';

      interactiveShellInit = ''
        set fish_greeting
      '' + (
        ''
          set -g _tide_color_dark_blue 0087AF
          set -g _tide_color_dark_green 5FAF00
          set -g _tide_color_gold D7AF00
          set -g _tide_color_green 5FD700
          set -g _tide_color_light_blue 00AFFF
        ''
        /* TODO for v5:
        let
          file = lib.fileContents "${self.inputs.fish-tide}/functions/_tide_sub_configure.fish";
          lines = lib.splitString "\n" file;
          commands = lib.take 5 lines;
        in lib.concatStringsSep "\n" commands + "\n"
        */
      ) + (
        let
          theme = lib.fileContents "${self.inputs.fish-tide}/functions/tide/configure/configs/lean.fish";
          lines = lib.splitString "\n" theme;
          commands = map (line: "set -U " + line) lines;
        in lib.concatStringsSep "\n" commands + "\n"
      ) + ''
        set -U tide_print_newline_before_prompt false
        # TODO for v5: set -U tide_prompt_add_newline_before false

        set -U tide_left_prompt_items context git status prompt_char
        # TODO for v5: set -U tide_left_prompt_items context git status character

        set -U tide_right_prompt_items jobs any_nix_shell pwd
        set -U tide_any_nix_shell_bg_color normal
      '';

      plugins = map (name: {
        inherit name;
        src = self.inputs."fish-${name}";
      }) [
        "tide"
        "abbreviation-tips"
        "autopair"
        # Alternative: https://github.com/decors/fish-colored-man
        # Allows configuring colors but has no command like `cless` for less uses other than man.
        "colored-man-pages"
      ];
    };
  };
}
