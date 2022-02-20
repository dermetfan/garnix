{ self, pkgs, ... }:

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

        # see https://github.com/IlanCosman/tide/blob/main/functions/tide/configure/configs/lean.fish

        set -U tide_print_newline_before_prompt false

        set -U tide_left_prompt_items context git status prompt_char
        set -U tide_left_prompt_item_separator_diff_color ' '
        set -U tide_left_prompt_item_separator_same_color ' '
        set -U tide_left_prompt_item_separator_same_color_color 949494

        set -U tide_right_prompt_items jobs any_nix_shell pwd
        set -U tide_right_prompt_item_separator_diff_color ' '
        set -U tide_right_prompt_item_separator_same_color ' '
        set -U tide_right_prompt_item_separator_same_color_color 949494

        set -U tide_any_nix_shell_bg_color normal

        set -U tide_prompt_char_bg_color normal
        set -U tide_prompt_char_failure_color FF0000
        set -U tide_prompt_char_icon '❯'
        set -U tide_prompt_char_success_color 5FD700
        set -U tide_prompt_char_vi_default_icon '❮'
        set -U tide_prompt_char_vi_insert_icon '❯'
        set -U tide_prompt_char_vi_replace_icon '▶'
        set -U tide_prompt_char_vi_visual_icon V
        set -U tide_pwd_bg_color normal
        set -U tide_pwd_color_anchors 00AFFF
        set -U tide_pwd_color_dirs 0087AF
        set -U tide_pwd_color_truncated_dirs 8787AF
        set -U tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .shorten_folder_marker .svn .terraform Cargo.toml composer.json CVS go.mod package.json
        set -U tide_pwd_truncate_margin 50
        set -U tide_pwd_unwritable_icon ''
        set -U tide_context_always_display false
        set -U tide_context_bg_color normal
        set -U tide_context_default_color D7AF87
        set -U tide_context_root_color D7AF00
        set -U tide_context_ssh_color D7AF87
        set -U tide_git_bg_color normal
        set -U tide_git_branch_color 5FD700
        set -U tide_git_conflicted_color FF0000
        set -U tide_git_dirty_color D7AF00
        set -U tide_git_operation_color FF0000
        set -U tide_git_staged_color D7AF00
        set -U tide_git_stash_color 5FD700
        set -U tide_git_untracked_color 00AFFF
        set -U tide_git_upstream_color 5FD700
        set -U tide_jobs_bg_color normal
        set -U tide_jobs_color 5FAF00
        set -U tide_jobs_icon ''
        set -U tide_status_failure_bg_color normal
        set -U tide_status_failure_color D70000
        set -U tide_status_failure_icon '✘'
        set -U tide_status_success_bg_color normal
        set -U tide_status_success_color 5FAF00
        set -U tide_status_success_icon '✔'
        set -U tide_vi_mode_default_bg_color 444444
        set -U tide_vi_mode_default_color 87af00
        set -U tide_vi_mode_default_icon DEFAULT
        set -U tide_vi_mode_insert_bg_color 444444
        set -U tide_vi_mode_insert_color
        set -U tide_vi_mode_insert_icon
        set -U tide_vi_mode_replace_bg_color 444444
        set -U tide_vi_mode_replace_color d78700
        set -U tide_vi_mode_replace_icon REPLACE
        set -U tide_vi_mode_visual_bg_color 444444
        set -U tide_vi_mode_visual_color 5f87d7
        set -U tide_vi_mode_visual_icon VISUAL
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
