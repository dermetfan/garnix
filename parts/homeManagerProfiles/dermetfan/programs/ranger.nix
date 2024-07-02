{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.ranger;
in {
  options.profiles.dermetfan.programs.ranger.enable = lib.mkEnableOption "ranger" // {
    default = config.programs.ranger.enable or false;
  };

  config = {
    home.packages = with pkgs; [
      atool
      xdragon
    ];

    programs.zoxide.enable = true;

    # default = config.home.sessionVariables.SHELL or null;
    # ${lib.optionalString (cfg.shell != null) "map S shell ${cfg.shell}"}

    programs.ranger = {
      mappings = {
        K  = "reload_cwd";
        h  = "display_file";
        k  = "chain draw_possible_programs; console open_with%space";
        yD = "shell -f xdragon -x %p";

        j = "search_next";
        J = "search_next forward=False";

        R = "move up=0.5    pages=True";
        I = "move down=0.5  pages=True";

        gm = "cd /run/media/${config.home.username}";
        gM = "cd /media";
        gs = "cd /tmp";

        lr = "set sort_reverse!";
        lz = "set sort=random";
        ls = "chain set sort=size;      set sort_reverse=False";
        lb = "chain set sort=basename;  set sort_reverse=False";
        ln = "chain set sort=natural;   set sort_reverse=False";
        lm = "chain set sort=mtime;     set sort_reverse=False";
        lc = "chain set sort=ctime;     set sort_reverse=False";
        la = "chain set sort=atime;     set sort_reverse=False";
        lt = "chain set sort=type;      set sort_reverse=False";
        le = "chain set sort=extension; set sort_reverse=False";

        lS = "chain set sort=size;      set sort_reverse=True";
        lB = "chain set sort=basename;  set sort_reverse=True";
        lN = "chain set sort=natural;   set sort_reverse=True";
        lM = "chain set sort=mtime;     set sort_reverse=True";
        lC = "chain set sort=ctime;     set sort_reverse=True";
        lA = "chain set sort=atime;     set sort_reverse=True";
        lT = "chain set sort=type;      set sort_reverse=True";
        lE = "chain set sort=extension; set sort_reverse=True";

        zv = "set vcs_aware!";
        zV = "set use_preview_script!";
      };

      settings = {
        vcs_backend_hg = "local";
        vcs_backend_git = "local";

        unicode_ellipsis = true;

        tilde_in_titlebar = true;
      };

      extraConfig = ''
        copymap <UP>    r
        copymap <DOWN>  i
        copymap <LEFT>  n
        copymap <RIGHT> o

        copymap R <C-U>
        copymap I <C-D>
      '';

      plugins = [
        {
          name = "zoxide";
          # TODO fetch as flake input
          src = pkgs.fetchFromGitHub {
            owner = "jchook";
            repo = "ranger-zoxide";
            rev = "b03a5f18939d4bde3a346b221b478410cfb87096";
            sha256 = "0dddaqm3ipz4cw0m7ynnmkrcxfnnvdsm3c7l7711wmqnkmbjxvrr";
          };
        }
      ];

      rifle = let
        env = name: if config.home.sessionVariables ? ${name}
          then config.home.sessionVariables.${name}
          else "\$${name}";
        EDITOR = env "EDITOR";
        PAGER  = env "PAGER";
      in [
        ## Misc

        { condition = "mime ^text,  label editor";                                                              command = ''${EDITOR} -- "$@"''; }
        { condition = "mime ^text,  label pager ";                                                              command = ''${PAGER}  -- "$@"''; }
        { condition = "mime ^text,  X, has geany,   flag f";                                                    command = ''geany     -- "$@"''; }
        { condition = "!mime ^text, label editor, ext xml|json|yml|yaml|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix"; command = ''${EDITOR} -- "$@"''; }
        { condition = "!mime ^text, label pager,  ext xml|json|yml|yaml|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix"; command = ''${PAGER}  -- "$@"''; }

        { condition = "ext 1";                         command = ''man        "$1"''; }
        { condition = "ext s[wmf]c, has zsnes, X";     command = ''zsnes      "$1"''; }
        { condition = "ext s[wmf]c, has snes9x-gtk,X"; command = ''snes9x-gtk "$1"''; }
        { condition = "ext nes, has fceux, X";         command = ''fceux      "$1"''; }
        { condition = "ext exe";                       command = ''wine       "$1"''; }
        { condition = "name ^[mM]akefile$";            command = ''make'';            }

        ## Websites

        { condition = "ext x?html?, has surf,           X, flag f"; command = ''surf  -- file://"$1"''; }
        { condition = "ext x?html?, has vimprobable,    X, flag f"; command = ''vimprobable  -- "$@"''; }
        { condition = "ext x?html?, has vimprobable2,   X, flag f"; command = ''vimprobable2 -- "$@"''; }
        { condition = "ext x?html?, has qutebrowser,    X, flag f"; command = ''qutebrowser  -- "$@"''; }
        { condition = "ext x?html?, has dwb,            X, flag f"; command = ''dwb          -- "$@"''; }
        { condition = "ext x?html?, has jumanji,        X, flag f"; command = ''jumanji      -- "$@"''; }
        { condition = "ext x?html?, has luakit,         X, flag f"; command = ''luakit       -- "$@"''; }
        { condition = "ext x?html?, has uzbl,           X, flag f"; command = ''uzbl         -- "$@"''; }
        { condition = "ext x?html?, has uzbl-tabbed,    X, flag f"; command = ''uzbl-tabbed  -- "$@"''; }
        { condition = "ext x?html?, has uzbl-browser,   X, flag f"; command = ''uzbl-browser -- "$@"''; }
        { condition = "ext x?html?, has uzbl-core,      X, flag f"; command = ''uzbl-core    -- "$@"''; }
        { condition = "ext x?html?, has firefox,        X, flag f"; command = ''firefox      -- "$@"''; }
        { condition = "ext x?html?, has chromium,       X, flag f"; command = ''chromium     -- "$@"''; }
        { condition = "ext x?html?, has vivaldi,        X, flag f"; command = ''vivaldi      -- "$@"''; }
        { condition = "ext x?html?, has opera,          X, flag f"; command = ''opera        -- "$@"''; }
        { condition = "ext x?html?, has midori,         X, flag f"; command = ''midori       -- "$@"''; }
        { condition = "ext x?html?, has seamonkey,      X, flag f"; command = ''seamonkey    -- "$@"''; }
        { condition = "ext x?html?, has iceweasel,      X, flag f"; command = ''iceweasel    -- "$@"''; }
        { condition = "ext x?html?, has epiphany,       X, flag f"; command = ''epiphany     -- "$@"''; }
        { condition = "ext x?html?, has konqueror,      X, flag f"; command = ''konqueror    -- "$@"''; }
        { condition = "ext x?html?, has elinks,          terminal"; command = ''elinks          "$@"''; }
        { condition = "ext x?html?, has links2,          terminal"; command = ''links2          "$@"''; }
        { condition = "ext x?html?, has links,           terminal"; command = ''links           "$@"''; }
        { condition = "ext x?html?, has lynx,            terminal"; command = ''lynx         -- "$@"''; }
        { condition = "ext x?html?, has w3m,             terminal"; command = ''w3m             "$@"''; }

        ## Code

        { condition = "ext py";  command = ''python -- "$1"''; }
        { condition = "ext pl";  command = ''perl   -- "$1"''; }
        { condition = "ext rb";  command = ''ruby   -- "$1"''; }
        { condition = "ext js";  command = ''node   -- "$1"''; }
        { condition = "ext sh";  command = ''sh     -- "$1"''; }
        { condition = "ext php"; command = ''php    -- "$1"''; }
        { condition = "ext jar"; command = ''java -jar "$1"''; }

        ## Audio without X

        { condition = "mime ^audio|ogg$, terminal, has mpv     "; command = ''mpv      -- "$@"''; }
        { condition = "mime ^audio|ogg$, terminal, has mplayer2"; command = ''mplayer2 -- "$@"''; }
        { condition = "mime ^audio|ogg$, terminal, has mplayer "; command = ''mplayer  -- "$@"''; }
        { condition = "ext midi?,        terminal, has wildmidi"; command = ''wildmidi -- "$@"''; }

        ## Video/Audio with a GUI

        { condition = "mime ^video|audio, has gmplayer, X, flag f"; command = ''gmplayer           -- "$@"''; }
        { condition = "mime ^video|audio, has smplayer, X, flag f"; command = ''smplayer              "$@"''; }
        { condition = "mime ^video,       has mpv,      X, flag f"; command = ''mpv                -- "$@"''; }
        { condition = "mime ^video,       has mpv,      X, flag f"; command = ''mpv --fs           -- "$@"''; }
        { condition = "mime ^video,       has mplayer2, X, flag f"; command = ''mplayer2           -- "$@"''; }
        { condition = "mime ^video,       has mplayer2, X, flag f"; command = ''mplayer2 -fs       -- "$@"''; }
        { condition = "mime ^video,       has mplayer,  X, flag f"; command = ''mplayer            -- "$@"''; }
        { condition = "mime ^video,       has mplayer,  X, flag f"; command = ''mplayer -fs        -- "$@"''; }
        { condition = "mime ^video|audio, has vlc,      X, flag f"; command = ''vlc                -- "$@"''; }
        { condition = "mime ^video|audio, has totem,    X, flag f"; command = ''totem              -- "$@"''; }
        { condition = "mime ^video|audio, has totem,    X, flag f"; command = ''totem --fullscreen -- "$@"''; }

        ## Video without X

        { condition = "mime ^video, terminal, !X, has mpv";      command = ''mpv      -- "$@"''; }
        { condition = "mime ^video, terminal, !X, has mplayer2"; command = ''mplayer2 -- "$@"''; }
        { condition = "mime ^video, terminal, !X, has mplayer";  command = ''mplayer  -- "$@"''; }

        ## Documents

        { condition = "ext pdf, has llpp,     X, flag f"; command = ''llpp        "$@"''; }
        { condition = "ext pdf, has zathura,  X, flag f"; command = ''zathura  -- "$@"''; }
        { condition = "ext pdf, has mupdf,    X, flag f"; command = ''mupdf       "$@"''; }
        { condition = "ext pdf, has mupdf-x11,X, flag f"; command = ''mupdf-x11   "$@"''; }
        { condition = "ext pdf, has apvlv,    X, flag f"; command = ''apvlv    -- "$@"''; }
        { condition = "ext pdf, has xpdf,     X, flag f"; command = ''xpdf     -- "$@"''; }
        { condition = "ext pdf, has evince,   X, flag f"; command = ''evince   -- "$@"''; }
        { condition = "ext pdf, has atril,    X, flag f"; command = ''atril    -- "$@"''; }
        { condition = "ext pdf, has okular,   X, flag f"; command = ''okular   -- "$@"''; }
        { condition = "ext pdf, has epdfview, X, flag f"; command = ''epdfview -- "$@"''; }
        { condition = "ext pdf, has qpdfview, X, flag f"; command = ''qpdfview    "$@"''; }

        { condition = "ext docx?, has catdoc, terminal"; command = ''catdoc -- "$@" | "${PAGER}"''; }

        { condition = "ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has gnumeric,    X, flag f"; command = ''gnumeric -- "$@"''; }
        { condition = "ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has kspread,     X, flag f"; command = ''kspread  -- "$@"''; }
        { condition = "ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has libreoffice, X, flag f"; command = ''libreoffice "$@"''; }
        { condition = "ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has soffice,     X, flag f"; command = ''soffice     "$@"''; }
        { condition = "ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has ooffice,     X, flag f"; command = ''ooffice     "$@"''; }

        { condition = "ext djvu, has zathura,X, flag f"; command = ''zathura -- "$@"''; }
        { condition = "ext djvu, has evince, X, flag f"; command = ''evince  -- "$@"''; }
        { condition = "ext djvu, has atril,  X, flag f"; command = ''atril   -- "$@"''; }

        ## Image Viewing

        { condition = "mime ^image/svg, has inkscape, X, flag f"; command = ''inkscape -- "$@"''; }
        { condition = "mime ^image/svg, has display,  X, flag f"; command = ''display  -- "$@"''; }

        { condition = "mime ^image, has pqiv,      X, flag f"; command = ''pqiv             -- "$@"''; }
        { condition = "mime ^image, has sxiv,      X, flag f"; command = ''sxiv             -- "$@"''; }
        { condition = "mime ^image, has feh,       X, flag f"; command = ''feh --scale-down -- "$@"''; }
        { condition = "mime ^image, has mirage,    X, flag f"; command = ''mirage           -- "$@"''; }
        { condition = "mime ^image, has ristretto, X, flag f"; command = ''ristretto           "$@"''; }
        { condition = "mime ^image, has eog,       X, flag f"; command = ''eog              -- "$@"''; }
        { condition = "mime ^image, has eom,       X, flag f"; command = ''eom              -- "$@"''; }
        { condition = "mime ^image, has gimp,      X, flag f"; command = ''gimp             -- "$@"''; }
        { condition = "ext xcf,                    X, flag f"; command = ''gimp             -- "$@"''; }

        ## Archives

        # avoid password prompt by providing empty password
        { condition = "ext 7z, has 7z"; command = ''7z -p l "$@" | "${PAGER}"''; }

        # This requires atool
        { condition = "ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip,    has als    "; command = ''als -- "$@" | "${PAGER}"''; }
        { condition = "ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip|7z, has aunpack"; command = ''aunpack -- "$@"''; }

        { condition = "ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|tar\.gz|xar|xpi|xz|zip|7z, has xarchiver, X, flag f"; command = ''xarchiver -- "$@"''; }

        # Fallback:
        { condition = "ext tar|gz, has tar"; command = ''tar vvtf "$@" | "${PAGER}"''; }
        { condition = "ext tar|gz, has tar"; command = ''tar vvxf "$@"''; }

        ## Misc

        { condition = "label wallpaper, number 11, mime ^image, has feh, X"; command = ''eh --bg-scale "$1"''; }
        { condition = "label wallpaper, number 12, mime ^image, has feh, X"; command = ''eh --bg-tile "$1"''; }
        { condition = "label wallpaper, number 13, mime ^image, has feh, X"; command = ''eh --bg-center "$1"''; }
        { condition = "label wallpaper, number 14, mime ^image, has feh, X"; command = ''eh --bg-fill "$1"''; }

        # Define the editor for non-text files + pager as last action
        { condition = "              !mime ^text, !ext xml|json|yml|yaml|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix"; command = ''sk''; }
        { condition = "label editor, !mime ^text, !ext xml|json|yml|yaml|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix"; command = ''{EDITOR} -- "$@"''; }
        { condition = "label pager,  !mime ^text, !ext xml|json|yml|yaml|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix"; command = ''{PAGER} -- "$@"''; }

        # The very last action, so that it's never triggered accidentally, is to execute a program:
        { condition = "mime application/x-executable"; command = ''$1"''; }
      ];
    };
  };
}
