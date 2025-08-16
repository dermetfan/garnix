let
  entries = [
    {
      category = "Files";
      package = "du-dust";
      executable = "dust";
    }
    {
      category = "Files";
      package = "sd";
    }
    {
      category = "Files";
      package = "ratarmount";
    }
    {
      category = "Files";
      package = "fclones";
    }
    {
      category = "Files";
      package = "fq";
    }
    {
      category = "Streams";
      package = "peco";
    }
    {
      category = "Streams";
      package = "fzy";
    }
    {
      category = "Streams";
      package = "tailspin";
    }
    {
      category = "Developent/Tools";
      package = "below";
    }
    {
      category = "Developent/Tools";
      package = "scc";
    }
    {
      category = "Developent/Tools";
      package = "jnv";
    }
    {
      category = "Developent/Tools";
      package = "ijq";
    }
    {
      category = "Developent/Tools";
      package = "fq";
    }
    {
      category = "Developent/Tools";
      package = "gron";
    }
    {
      category = "Developent/Tools/Nix";
      package = "deadnix";
    }
    {
      category = "Developent/Tools/Nix";
      package = "statix";
    }
    {
      category = "Developent/Tools/Nix";
      package = "nix-linter";
    }
    {
      category = "Hardware";
      package = "glances";
    }
    {
      category = "Hardware";
      package = "bottom";
      executable = "btm";
    }
    {
      category = "Hardware";
      package = "btop";
    }
    {
      category = "Hardware";
      package = "iotop";
    }
    {
      category = "Hardware";
      flake = "github:macunha1/configuration.nix";
      package = "uhk-agent";
    }
    {
      category = "Hardware";
      package = "smartmontools";
    }
    {
      category = "Hardware";
      package = "hdparm";
    }
    {
      category = "Hardware";
      package = "parted";
    }
    {
      category = "Hardware";
      package = "gparted";
    }
    {
      category = "Hardware";
      package = "gptfdisk";
    }
    {
      category = "Hardware";
      package = "glxinfo";
    }
    {
      category = "Networking";
      package = "doggo";
    }
    {
      category = "Networking";
      package = "sipcalc";
    }
    {
      category = "Networking";
      package = "trippy";
    }
    {
      category = "Networking";
      package = "wakelan";
    }
    {
      category = "Networking";
      package = "gotty";
    }
    {
      category = "Networking";
      package = "upterm";
    }
    {
      category = "Networking";
      package = "mitmproxy";
    }
    {
      category = "Networking";
      package = "nethogs";
    }
    {
      category = "Networking";
      package = "ngrep";
    }
    {
      category = "Networking";
      package = "filezilla";
    }
    {
      category = "Networking";
      package = "wget";
    }
    {
      category = "Security";
      package = "cariddi";
    }
    {
      category = "Compression";
      package = "lrzip";
    }
    {
      category = "Documents/PDF";
      package = "krop";
    }
    {
      category = "Documents/PDF";
      package = "pdfarranger";
    }
    {
      category = "Ricing";
      package = "neofetch";
    }
    {
      category = "Telephony";
      package = "ncid";
    }
    {
      category = "Terminal";
      package = "asciinema";
    }
    {
      category = "Terminal";
      package = "pspg";
    }
  ];
in

parts:

final: prev: {
  catalog = prev.writeShellApplication {
    name = "catalog";

    runtimeInputs = [ prev.broot ];

    text = let
      catalog = prev.symlinkJoin {
        name = "catalog";
        paths = map (entry: prev.writeTextFile rec {
          name = entry.package;
          text = ''
            nix shell ${prev.lib.escapeShellArg (entry.flake or "nixpkgs")}#${prev.lib.escapeShellArg name} \
              -c ${prev.lib.escapeShellArg (entry.executable or name)} "$@"
          '';
          executable = true;
          destination = "/${entry.category}/${name} — " + (
            prev.lib.replaceStrings [ "/" ] [ "|" ] (
              prev.${entry.package}.meta.description or "(no description)"
            )
          );
        }) entries;
      };

      conf = prev.writeText "conf.hjson" (__toJSON {
        quit_on_last_cancel = true;
        verbs = [
          {
            key = "enter";
            execution = "echo {file}";
            leave_broot = true;
          }
        ];
        skin = {
          # Give background the same color as link targets so they are invisible.
          default = "gray(23) rgb(38, 38, 38) / gray(20) rgb(38, 38, 38)";
          file = "rgb(38, 38, 38) None";

          # Make links look like executables.
          link = "Cyan None";
        };
      });
    in ''
      exe=$(broot --conf ${conf} ${catalog})
      if [[ -n "$exe" ]]; then
          exec "$exe"
      fi
    '';
  };
}
