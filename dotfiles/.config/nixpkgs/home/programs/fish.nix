{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.fish;
in {
  options.config.programs.fish.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.fish.enable;
    defaultText = "<option>programs.fish.enable</option>";
    description = "Whether to configure fish.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; }) # tide
      any-nix-shell
    ];

    programs = {
      exa.enable = true;
      zoxide.enable = true;
      jq.enable = true; # dependency of the done plugin on sway

      fish = {
        shellAliases = {
          ls = "exa --group-directories-first";
          l  = "exa -lga --group-directories-first";
          ll = "exa -lg --group-directories-first";
          less = "less -R";
          diff = "diff -r --suppress-common-lines";
          watch = "watch --color";
          pv = "pv -pea";
        };

        shellInit = ''
          any-nix-shell fish --info-right | source
        '';

        interactiveShellInit = ''
          set fish_greeting

          theme_gruvbox dark hard

          # ayu Dark
          set -U fish_color_normal B3B1AD
          set -U fish_color_command 39BAE6
          set -U fish_color_quote C2D94C
          set -U fish_color_redirection FFEE99
          set -U fish_color_end F29668
          set -U fish_color_error FF3333
          set -U fish_color_param B3B1AD
          set -U fish_color_selection E6B450
          set -U fish_color_search_match E6B450
          set -U fish_color_history_current --bold
          set -U fish_color_operator E6B450
          set -U fish_color_escape 95E6CB
          set -U fish_color_cwd 59C2FF
          set -U fish_color_cwd_root red
          set -U fish_color_valid_path --underline
          set -U fish_color_autosuggestion 4D5566
          set -U fish_color_user brgreen
          set -U fish_color_host normal
          set -U fish_color_cancel -r
          set -U fish_pager_color_completion normal
          set -U fish_pager_color_description B3A06D yellow
          set -U fish_pager_color_prefix white --bold --underline
          set -U fish_pager_color_progress brwhite --background=cyan
          set -U fish_color_comment 626A73
          set -U fish_color_match F07178
        '';

        promptInit = ''
          # see https://github.com/IlanCosman/tide/blob/main/functions/tide/configure/configs/lean.fish

          set -U tide_print_newline_before_prompt false

          set -U tide_left_prompt_items context git status prompt_char
          set -U tide_left_prompt_item_separator_diff_color ' '
          set -U tide_left_prompt_item_separator_same_color ' '
          set -U tide_left_prompt_item_separator_same_color_color 949494

          set -U tide_right_prompt_items jobs pwd
          set -U tide_right_prompt_item_separator_diff_color ' '
          set -U tide_right_prompt_item_separator_same_color ' '
          set -U tide_right_prompt_item_separator_same_color_color 949494

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

        plugins = [
          {
            name = "gruvbox";
            src = pkgs.fetchFromGitHub {
              owner = "Jomik";
              repo = "fish-gruvbox";
              rev = "d8c0463518fb95bed8818a1e7fe5da20cffe6fbd";
              sha256 = "0hkps4ddz99r7m52lwyzidbalrwvi7h2afpawh9yv6a226pjmck7";
            };
          }
          {
            name = "tide";
            src = pkgs.fetchFromGitHub {
              owner = "IlanCosman";
              repo = "tide";
              rev = "630ae9f7d93c5f53880e7d59ae4e61f6390b71a1";
              sha256 = "1laiqnjjq7rpqinnfmi33axxp9nv2ziw0i6ryi7705cx0f6n8fjx";
            };
          }
          {
            name = "abbreviation-tips";
            src = pkgs.fetchFromGitHub {
              owner = "Gazorby";
              repo = "fish-abbreviation-tips";
              rev = "6b48f50dbb214324d340c351cc8e7dd6047dda50";
              sha256 = "11im39l2vcvwavdnh3bnh3vr01hdw4kxxjanyjkyzfs7wgzddjbs";
            };
          }
          {
            name = "autopair";
            src = pkgs.fetchFromGitHub {
              owner = "jorgebucaran";
              repo = "autopair.fish";
              rev = "1222311994a0730e53d8e922a759eeda815fcb62";
              sha256 = "0lxfy17r087q1lhaz5rivnklb74ky448llniagkz8fy393d8k9cp";
            };
          }
          {
            name = "done";
            src = pkgs.fetchFromGitHub {
              owner = "franciscolourenco";
              repo = "done";
              rev = "7fda8f2c3e79835d5c1e6721fa48fe5ed4ba0858";
              sha256 = "1snysg52fr1h6n188jhqzny4sfgzcjgpa9r9qvj9smkg7zmplmsy";
            };
          }
        ];
      };
    };
  };
}
