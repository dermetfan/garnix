{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.ranger;
in {
  options.config.programs.ranger.enable = lib.mkEnableOption "ranger";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        ranger
        atool
      ];

      file = let
        env = name: if config.home.sessionVariables ? ${name}
          then config.home.sessionVariables.${name}
          else "${name}";
        EDITOR = env "EDITOR";
        PAGER  = env "PAGER";
      in {
        ".config/ranger/rc.conf".text = ''
          # ===================================================================
          # == Options
          # ===================================================================

          # State of the three backends git, hg, bzr. The possible states are
          # disabled, local (only show local info), enabled (show local and remote
          # information).
          set vcs_backend_hg local
          set vcs_backend_git local

          # Use a unicode "..." character to mark cut-off filenames?
          set unicode_ellipsis true

          # Abbreviate $HOME with ~ in the titlebar (first line) of ranger?
          set tilde_in_titlebar true

          # ===================================================================
          # == Define keys for the browser
          # ===================================================================

          # Basic
          map K reload_cwd

          map h display_file

          map k chain draw_possible_programs; console open_with%%space

          # Searching
          map j  search_next
          map J  search_next forward=False

          # VIM-like
          copymap <UP>    r
          copymap <DOWN>  i
          copymap <LEFT>  n
          copymap <RIGHT> o

          map R  move up=0.5    pages=True
          map I  move down=0.5  pages=True
          copymap R <C-U>
          copymap I <C-D>

          # Jumping around
          map gm cd /run/media/${builtins.getEnv "USER"}
          map gM cd /media
          map gs cd /tmp

          # Sorting
          map lr set sort_reverse!
          map lz set sort=random
          map ls chain set sort=size;      set sort_reverse=False
          map lb chain set sort=basename;  set sort_reverse=False
          map ln chain set sort=natural;   set sort_reverse=False
          map lm chain set sort=mtime;     set sort_reverse=False
          map lc chain set sort=ctime;     set sort_reverse=False
          map la chain set sort=atime;     set sort_reverse=False
          map lt chain set sort=type;      set sort_reverse=False
          map le chain set sort=extension; set sort_reverse=False

          map lS chain set sort=size;      set sort_reverse=True
          map lB chain set sort=basename;  set sort_reverse=True
          map lN chain set sort=natural;   set sort_reverse=True
          map lM chain set sort=mtime;     set sort_reverse=True
          map lC chain set sort=ctime;     set sort_reverse=True
          map lA chain set sort=atime;     set sort_reverse=True
          map lT chain set sort=type;      set sort_reverse=True
          map lE chain set sort=extension; set sort_reverse=True

          # Settings
          map zv set vcs_aware!
          map zV set use_preview_script!
        '';

        ".config/ranger/rifle.conf".text = ''
          # vim: ft=cfg
          #
          # This is the configuration file of "rifle", ranger's file executor/opener.
          # Each line consists of conditions and a command.  For each line the conditions
          # are checked and if they are met, the respective command is run.
          #
          # Syntax:
          #   <condition1> , <condition2> , ... = command
          #
          # The command can contain these environment variables:
          #   $1-$9 | The n-th selected file
          #   $@    | All selected files
          #
          # If you use the special command "ask", rifle will ask you what program to run.
          #
          # Prefixing a condition with "!" will negate its result.
          # These conditions are currently supported:
          #   match <regexp> | The regexp matches $1
          #   ext <regexp>   | The regexp matches the extension of $1
          #   mime <regexp>  | The regexp matches the mime type of $1
          #   name <regexp>  | The regexp matches the basename of $1
          #   path <regexp>  | The regexp matches the absolute path of $1
          #   has <program>  | The program is installed (i.e. located in $PATH)
          #   env <variable> | The environment variable "variable" is non-empty
          #   file           | $1 is a file
          #   directory      | $1 is a directory
          #   number <n>     | change the number of this command to n
          #   terminal       | stdin, stderr and stdout are connected to a terminal
          #   X              | $DISPLAY is not empty (i.e. Xorg runs)
          #
          # There are also pseudo-conditions which have a "side effect":
          #   flag <flags>  | Change how the program is run. See below.
          #   label <label> | Assign a label or name to the command so it can
          #                 | be started with :open_with <label> in ranger
          #                 | or `rifle -p <label>` in the standalone executable.
          #   else          | Always true.
          #
          # Flags are single characters which slightly transform the command:
          #   f | Fork the program, make it run in the background.
          #     |   New command = setsid $command >& /dev/null &
          #   r | Execute the command with root permissions
          #     |   New command = sudo $command
          #   t | Run the program in a new terminal.  If $TERMCMD is not defined,
          #     | rifle will attempt to extract it from $TERM.
          #     |   New command = $TERMCMD -e $command
          # Note: The "New command" serves only as an illustration, the exact
          # implementation may differ.
          # Note: When using rifle in ranger, there is an additional flag "c" for
          # only running the current file even if you have marked multiple files.

          #-------------------------------------------
          # Websites
          #-------------------------------------------
          ext x?html?, has surf,           X, flag f = surf -- file://"$1"
          ext x?html?, has vimprobable,    X, flag f = vimprobable -- "$@"
          ext x?html?, has vimprobable2,   X, flag f = vimprobable2 -- "$@"
          ext x?html?, has qutebrowser,    X, flag f = qutebrowser -- "$@"
          ext x?html?, has dwb,            X, flag f = dwb -- "$@"
          ext x?html?, has jumanji,        X, flag f = jumanji -- "$@"
          ext x?html?, has luakit,         X, flag f = luakit -- "$@"
          ext x?html?, has uzbl,           X, flag f = uzbl -- "$@"
          ext x?html?, has uzbl-tabbed,    X, flag f = uzbl-tabbed -- "$@"
          ext x?html?, has uzbl-browser,   X, flag f = uzbl-browser -- "$@"
          ext x?html?, has uzbl-core,      X, flag f = uzbl-core -- "$@"
          ext x?html?, has vivaldi,        X, flag f = vivaldi -- "$@"
          ext x?html?, has midori,         X, flag f = midori -- "$@"
          ext x?html?, has chromium,       X, flag f = chromium -- "$@"
          ext x?html?, has opera,          X, flag f = opera -- "$@"
          ext x?html?, has firefox,        X, flag f = firefox -- "$@"
          ext x?html?, has seamonkey,      X, flag f = seamonkey -- "$@"
          ext x?html?, has iceweasel,      X, flag f = iceweasel -- "$@"
          ext x?html?, has epiphany,       X, flag f = epiphany -- "$@"
          ext x?html?, has konqueror,      X, flag f = konqueror -- "$@"
          ext x?html?, has elinks,          terminal = elinks "$@"
          ext x?html?, has links2,          terminal = links2 "$@"
          ext x?html?, has links,           terminal = links "$@"
          ext x?html?, has lynx,            terminal = lynx -- "$@"
          ext x?html?, has w3m,             terminal = w3m "$@"

          #-------------------------------------------
          # Misc
          #-------------------------------------------
          mime ^text,  label editor = ${EDITOR} -- "$@"
          mime ^text,  label pager  = ${PAGER} -- "$@"
          mime ^text,  X, has geany,   flag f = geany   -- "$@"
          !mime ^text, label editor, ext xml|json|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix = ${EDITOR} -- "$@"
          !mime ^text, label pager,  ext xml|json|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix = ${PAGER} -- "$@"

          ext 1                         = man "$1"
          ext s[wmf]c, has zsnes, X     = zsnes "$1"
          ext s[wmf]c, has snes9x-gtk,X = snes9x-gtk "$1"
          ext nes, has fceux, X         = fceux "$1"
          ext exe                       = wine "$1"
          name ^[mM]akefile$            = make

          #--------------------------------------------
          # Code
          #-------------------------------------------
          ext py  = python -- "$1"
          ext pl  = perl -- "$1"
          ext rb  = ruby -- "$1"
          ext js  = node -- "$1"
          ext sh  = sh -- "$1"
          ext php = php -- "$1"
          ext jar = java -jar "$1"

          #--------------------------------------------
          # Audio without X
          #-------------------------------------------
          mime ^audio|ogg$, terminal, has mpv      = mpv -- "$@"
          mime ^audio|ogg$, terminal, has mplayer2 = mplayer2 -- "$@"
          mime ^audio|ogg$, terminal, has mplayer  = mplayer -- "$@"
          ext midi?,        terminal, has wildmidi = wildmidi -- "$@"

          #--------------------------------------------
          # Video/Audio with a GUI
          #-------------------------------------------
          mime ^video|audio, has gmplayer, X, flag f = gmplayer -- "$@"
          mime ^video|audio, has smplayer, X, flag f = smplayer "$@"
          mime ^video,       has mpv,      X, flag f = mpv -- "$@"
          mime ^video,       has mpv,      X, flag f = mpv --fs -- "$@"
          mime ^video,       has mplayer2, X, flag f = mplayer2 -- "$@"
          mime ^video,       has mplayer2, X, flag f = mplayer2 -fs -- "$@"
          mime ^video,       has mplayer,  X, flag f = mplayer -- "$@"
          mime ^video,       has mplayer,  X, flag f = mplayer -fs -- "$@"
          mime ^video|audio, has vlc,      X, flag f = vlc -- "$@"
          mime ^video|audio, has totem,    X, flag f = totem -- "$@"
          mime ^video|audio, has totem,    X, flag f = totem --fullscreen -- "$@"

          #--------------------------------------------
          # Video without X:
          #-------------------------------------------
          mime ^video, terminal, !X, has mpv       = mpv -- "$@"
          mime ^video, terminal, !X, has mplayer2  = mplayer2 -- "$@"
          mime ^video, terminal, !X, has mplayer   = mplayer -- "$@"

          #-------------------------------------------
          # Documents
          #-------------------------------------------
          ext pdf, has llpp,     X, flag f = llpp "$@"
          ext pdf, has zathura,  X, flag f = zathura -- "$@"
          ext pdf, has mupdf,    X, flag f = mupdf "$@"
          ext pdf, has mupdf-x11,X, flag f = mupdf-x11 "$@"
          ext pdf, has apvlv,    X, flag f = apvlv -- "$@"
          ext pdf, has xpdf,     X, flag f = xpdf -- "$@"
          ext pdf, has evince,   X, flag f = evince -- "$@"
          ext pdf, has atril,    X, flag f = atril -- "$@"
          ext pdf, has okular,   X, flag f = okular -- "$@"
          ext pdf, has epdfview, X, flag f = epdfview -- "$@"
          ext pdf, has qpdfview, X, flag f = qpdfview "$@"

          ext docx?, has catdoc,       terminal = catdoc -- "$@" | "${PAGER}"

          ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has gnumeric,    X, flag f = gnumeric -- "$@"
          ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has kspread,     X, flag f = kspread -- "$@"
          ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has libreoffice, X, flag f = libreoffice "$@"
          ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has soffice,     X, flag f = soffice "$@"
          ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has ooffice,     X, flag f = ooffice "$@"

          ext djvu, has zathura,X, flag f = zathura -- "$@"
          ext djvu, has evince, X, flag f = evince -- "$@"
          ext djvu, has atril,  X, flag f = atril -- "$@"

          #-------------------------------------------
          # Image Viewing:
          #-------------------------------------------
          mime ^image/svg, has inkscape, X, flag f = inkscape -- "$@"
          mime ^image/svg, has display,  X, flag f = display -- "$@"

          mime ^image, has pqiv,      X, flag f = pqiv -- "$@"
          mime ^image, has sxiv,      X, flag f = sxiv -- "$@"
          mime ^image, has feh,       X, flag f = feh -- "$@"
          mime ^image, has mirage,    X, flag f = mirage -- "$@"
          mime ^image, has ristretto, X, flag f = ristretto "$@"
          mime ^image, has eog,       X, flag f = eog -- "$@"
          mime ^image, has eom,       X, flag f = eom -- "$@"
          mime ^image, has gimp,      X, flag f = gimp -- "$@"
          ext xcf,                    X, flag f = gimp -- "$@"

          #-------------------------------------------
          # Archives
          #-------------------------------------------
          # avoid password prompt by providing empty password
          ext 7z, has 7z = 7z -p l "$@" | "${PAGER}"
          # This requires atool
          ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip,    has als     = als -- "$@" | "${PAGER}"
          ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip|7z, has aunpack = aunpack -- "$@"

          ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|tar\.gz|xar|xpi|xz|zip|7z, has xarchiver, X, flag f = xarchiver -- "$@"

          # Fallback:
          ext tar|gz, has tar = tar vvtf "$@" | "${PAGER}"
          ext tar|gz, has tar = tar vvxf "$@"

          #-------------------------------------------
          # Misc
          #-------------------------------------------
          label wallpaper, number 11, mime ^image, has feh, X = feh --bg-scale "$1"
          label wallpaper, number 12, mime ^image, has feh, X = feh --bg-tile "$1"
          label wallpaper, number 13, mime ^image, has feh, X = feh --bg-center "$1"
          label wallpaper, number 14, mime ^image, has feh, X = feh --bg-fill "$1"

          # Define the editor for non-text files + pager as last action
                        !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix = ask
          label editor, !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix = ${EDITOR} -- "$@"
          label pager,  !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php|lua|rs|nix = ${PAGER} -- "$@"

          # The very last action, so that it's never triggered accidentally, is to execute a program:
          mime application/x-executable = "$1"
        '';

        ".config/ranger/bookmarks".text = ''
          w:/data/dermetfan/projects/workspaces/development
          d:/data/dermetfan
        '';
      };
    };
  };
}
