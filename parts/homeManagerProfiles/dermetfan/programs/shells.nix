{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.shells;
in {
  options.profiles.dermetfan.programs.shells.enable = with lib; mkEnableOption "common shells" // {
    default = with config.programs;
      bash.enable || zsh.enable || fish.enable;
    defaultText = ''
      <option>
      with config.programs;
      bash.enable || zsh.enable || fish.enable
      </option>
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.fira-code ];

    programs = let
      aliases = {
        l  = "eza --git-ignore";
        ll = "eza --all";
      };
    in {
      eza.enable = true;

      nix-your-shell = {
        enable = true;
        nix-output-monitor.enable = true;
      };

      starship = {
        enable = true;
        enableTransience = true;
        presets = [
          "nerd-font-symbols"
        ];
        settings = {
          format = "$character";
          # `$all` without `$time` (and `$character`, as that's already in `format`)
          # https://starship.rs/config/#default-prompt-format
          right_format = lib.concatStrings [ "$username" "$hostname" "$localip" "$shlvl" "$singularity" "$kubernetes" "$nats" "$directory" "$vcsh" "$fossil_branch" "$fossil_metrics" "$git_branch" "$git_commit" "$git_state" "$git_metrics" "$git_status" "$hg_branch" "$hg_state" "$pijul_channel" "$docker_context" "$package" "$bun" "$c" "$cmake" "$cobol" "$cpp" "$daml" "$dart" "$deno" "$dotnet" "$elixir" "$elm" "$erlang" "$fennel" "$fortran" "$gleam" "$golang" "$gradle" "$haskell" "$haxe" "$helm" "$java" "$julia" "$kotlin" "$lua" "$maven" "$mojo" "$nim" "$nodejs" "$ocaml" "$odin" "$opa" "$perl" "$php" "$pulumi" "$purescript" "$python" "$quarto" "$raku" "$rlang" "$red" "$ruby" "$rust" "$scala" "$solidity" "$swift" "$terraform" "$typst" "$vlang" "$vagrant" "$xmake" "$zig" "$buf" "$guix_shell" "$nix_shell" "$conda" "$pixi" "$meson" "$spack" "$memory_usage" "$aws" "$gcloud" "$openstack" "$azure" "$direnv" "$env_var" "$mise" "$crystal" "$custom" "$sudo" "$cmd_duration" "$line_break" "$jobs" "$battery" "$status" "$container" "$netns" "$os" "$shell" ];

          # XXX No idea why this is true by default.
          # `lib.trace (builtins.toJSON options.programs.starship.settings.definitionsWithLocations)`
          # shows that _something_ sets some defaults, but I can't find it anywhere...
          cmd_duration.disabled = lib.mkForce false;

          direnv.disabled = false;
          pijul_channel.disabled = false;
          time.disabled = false;

          docker_context.disabled = true;

          directory.truncation_symbol = "…/";
        };
      };

      # https://starship.rs/advanced-config/#transientprompt-and-transientrightprompt-in-fish
      fish.functions = {
        starship_transient_prompt_func.body = ''
          starship module $argv character
        '';

        starship_transient_rprompt_func = ''
          set cmd_duration (starship module $argv cmd_duration)
          if [ -n $cmd_duration ]
            printf %s $cmd_duration
            starship module $argv time
          end
        '';
      };

      bash.shellAliases = aliases;
      zsh .shellAliases = aliases;
      fish.shellAliases = aliases;
    };
  };
}
