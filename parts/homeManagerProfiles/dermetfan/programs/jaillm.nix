{ self, config, lib, pkgs, ... }:

let
  cfg = config.programs.jaillm;
in {
  options.programs.jaillm.enable = lib.mkEnableOption "jaillm";

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton (self.inputs.jaillm.lib.jaillm pkgs rec {
      entry = pkgs.writers.writeNuBin "entry" ''
        def --wrapped main [...args] {
          exec ...(if ($args | is-not-empty) {$args} else {[
            (${builtins.toJSON (map (llm: llm.meta.mainProgram) llms)} | input list --fuzzy)
          ]})
        }
      '';

      llms = [
        pkgs.codex
        pkgs.gemini-cli
        pkgs.github-copilot-cli

        (self.inputs.nix-wrapper-modules.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.crush;
          env.CRUSH_GLOBAL_CONFIG = pkgs.writers.writeJSON "crush.json" {
            lsp = {
              nix.command = lib.getExe self.inputs.nil.packages.${pkgs.stdenv.hostPlatform.system}.default;
              go.command = lib.getExe pkgs.gopls;
              rust.command = lib.getExe pkgs.rust-analyzer;
              zig.command = lib.getExe pkgs.zls;
              haskell = {
                command = lib.getExe (pkgs.writeShellApplication {
                  # https://nixos.org/manual/nixpkgs/stable/#haskell-language-server
                  name = "haskell-language-server-wrapper-wrapper";
                  text = ''
                    if command -v haskell-language-server-wrapper >/dev/null 2>&1; then
                      exec haskell-language-server-wrapper "$@"
                    else
                      exec haskell-language-server "$@"
                    fi
                  '';
                });
                args = [ "--lsp" ];
              };
            };
            mcp = {
              nixos = {
                type = "stdio";
                command = lib.getExe pkgs.mcp-nixos;
              };
              serena = {
                type = "stdio";
                command = lib.getExe self.inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.default;
                args = [ "start-mcp-server" "--project-from-cwd" ];
              };
            };
            options.tui.compact_mode = true;
          };
        })

        (self.inputs.nix-wrapper-modules.wrappers.claude-code.wrap {
          inherit pkgs;
          mcpConfig = {
            nixos = {
              type = "stdio";
              command = lib.getExe pkgs.mcp-nixos;
            };
            serena = {
              type = "stdio";
              command = lib.getExe self.inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.default;
              args = [ "start-mcp-server" "--project-from-cwd" ];
            };
          };
          settings = {
            permissions.defaultMode = "bypassPermissions";
            cleanupPeriodDays = 3650;
            env = {
              DO_NOT_TRACK = 1;
              DISABLE_TELEMETRY = 1;
            };
          };
        })

        (self.inputs.nix-wrapper-modules.wrappers.opencode.wrap {
          inherit pkgs;
          settings.mcp = {
            nixos = {
              type = "local";
              command = lib.singleton (lib.getExe pkgs.mcp-nixos);
            };
            serena = {
              type = "local";
              command = [
                (lib.getExe self.inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.default)
                "start-mcp-server"
                "--project-from-cwd"
              ];
            };
          };
        })
      ];

      extraUtils = with pkgs; [
        jq
        jaq
        yq
        fd
        ripgrep
        less
        fish
        nushell
        which
        file
        libnotify
        direnv
        gitMinimal
        mercurial
        pijul
        gh
        claude-monitor

        (symlinkJoin {
          name = "nix-nondestructive";
          paths = [
            (writers.writeNuBin "nix" ''
              def --wrapped main [...args] {
                for arg in $args {
                  match $arg {
                    gc | delete | collect-garbage => {
                      print --stderr 'Destructive nix command blocked inside the AI jail.'
                      exit 1
                    }
                  }
                }

                exec ${lib.getExe nix} ...$args
              }
            '')

            (writers.writeNuBin "nix-collect-garbage" ''
              print --stderr 'nix-collect-garbage blocked inside the AI jail.'
              exit 1
            '')

            (writers.writeNuBin "nix-store" ''
              def --wrapped main [...args] {
                for arg in $args {
                  match $arg {
                    --gc | --delete => {
                      print --stderr 'Destructive nix-store command blocked inside the AI jail.'
                      exit 1
                    }
                  }
                }

                exec ${nix}/bin/nix-store ...$args
              }
            '')

            nix
          ];
        })
      ];

      extraCombinators = cs: [
        cs.notifications

        (cs.try-readonly (cs.noescape ''"$PWD"/.git''))
        (cs.try-readonly (cs.noescape ''"$PWD"/.hg''))
        (cs.try-readonly (cs.noescape ''"$PWD"/.pijul''))

        (let
          extraNixConfig = ''
            store = daemon
            accept-flake-config = true
          '';
        in cs.add-runtime ''
          nix_conf=$(mktemp --suffix jaillm-nix.conf)
          RUNTIME_ARGS+=(--ro-bind "$nix_conf" /etc/nix/nix.conf)

          cat /etc/nix/nix.conf - >> "$nix_conf" <<<${lib.escapeShellArg extraNixConfig}
        '')
        (cs.add-cleanup ''
          rm "$nix_conf"
        '')
        (cs.readonly "/nix/var/nix/daemon-socket/socket")

        (state: let
          runtimeArgs = pkgs.writers.writeNu "jaillm-direnv-bwrap-args" ''
            const path = ${lib.toJSON (state.env.PATH or null)}

            let export = direnv exec / direnv export json | from json

            let paths = $export
              | default {}
              | values
              | parse --regex `(^|[^\w/])/{0,}(?<path>/nix/store/[\w.-]+)`
              | get path
              | flatten

            let references = $paths
              | each {
                nix path-info --recursive --json --json-format 2 $in
                | from json
                | get info
                | values
                | each {|path| $path.references | each {$'($path.storeDir)/($in)'}}
                | flatten
              }
              | flatten

            $paths ++ $references
            | uniq
            | each {|path|
              print --no-newline "--ro-bind\u{0}"
              print --no-newline $"($path)\u{0}"
              print --no-newline $"($path)\u{0}"
            }

            $export
            | default {}
            | transpose key value
            | each {|var|
              print --no-newline "--setenv\u{0}"
              print --no-newline $"($var.key)\u{0}"
              if $var.key == PATH {
                print --no-newline $"($var.value)(if $path == null {'''} else {$':($path)'})\u{0}"
              } else {
                print --no-newline $"($var.value)\u{0}"
              }
            }

            ignore
          '';
        in cs.add-runtime ''
          exec {DIRENV_RUNTIME_ARGS_FD}< <(${runtimeArgs})
          RUNTIME_ARGS+=(--args "$DIRENV_RUNTIME_ARGS_FD")
        '' state)

        # Needs to be writable because serena canonicalizes this file on startup.
        (cs.wrap-entry (entry: let
          config = lib.generators.toYAML {} {
            gui_log_window = false;
            web_dashboard = false;
            web_dashboard_open_on_launch = false;
            projects = [];
          };
        in ''
          mkdir --parents ~/.serena
          printf %s ${lib.escapeShellArg config} > ~/.serena/serena_config.yml
          exec ${entry}
        ''))

        # Prevent keystore injection via `ioctl()`.
        (cs.add-seccomp (lib.getExe (pkgs.stdenv.mkDerivation rec {
          name = "tiocsti-seccomp-filter";
          dontUnpack = true;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.libseccomp ];
          src = "${self.inputs.opencode-bwrap}/opencode-bwrap/seccomp-tiocsti-filter.c";
          buildPhase = ''
            cc -O2 -Wall -Wextra -o gen "$src" -lseccomp
          '';
          installPhase = ''
            mkdir -p "$out/bin"
            install -m755 gen "$out/bin/${name}"
          '';
          meta.mainProgram = name;
        })))
      ];
    });
  };
}
