{ config, lib, pkgs, ... }:

{
  options.profiles.dermetfan.programs.yazi.enable = lib.mkEnableOption "yazi" // {
    default = config.programs.yazi.enable or false;
  };

  config = {
    home.packages = with pkgs; [
      # for the office plugin
      libreoffice
      poppler-utils
    ];

    programs.yazi = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      initLua = ''
        require("git"):setup()

        -- https://yazi-rs.github.io/docs/tips#symlink-in-status
        Status:children_add(function(self)
          local h = self._current.hovered
          if h and h.link_to then
            return " → " .. tostring(h.link_to)
          else
            return ""
          end
        end, 3300, Status.LEFT)

        -- https://yazi-rs.github.io/docs/tips#user-group-in-status
        Status:children_add(function()
          local h = cx.active.current.hovered
          if not h or ya.target_family() ~= "unix" then
            return ""
          end

          return ui.Line {
            ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
            ":",
            ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
            " ",
          }
        end, 500, Status.RIGHT)

        -- https://yazi-rs.github.io/docs/tips#username-hostname-in-header
        Header:children_add(function()
          if ya.target_family() ~= "unix" then
            return ""
          end
          return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
        end, 500, Header.LEFT)
      '';

      plugins = {
        inherit (pkgs.yaziPlugins)
          toggle-pane
          git
          time-travel
          jump-to-char
          office
          zoom;

        # https://yazi-rs.github.io/docs/tips#parent-arrow
        parent-arrow = pkgs.writeTextDir "main.lua" ''
          --- @sync entry
          local function entry(_, job)
            local parent = cx.active.parent
            if not parent then return end

            local offset = tonumber(job.args[1])
            if not offset then return ya.err(job.args[1], 'is not a number') end

            local start = parent.cursor + 1 + offset
            local end_ = offset < 0 and 1 or #parent.files
            local step = offset < 0 and -1 or 1
            for i = start, end_, step do
              local target = parent.files[i]
              if target and target.cha.is_dir then
                return ya.emit("cd", { target.url })
              end
            end
          end

          return { entry = entry }
        '';
      };

      settings = {
        mgr = {
          sort_by = "natural";
          sort_sensitive = true;
          sort_translit = true;
          wrap = true;
        };

        plugin = {
          prepend_fetchers = [
            # git plugin
            { id = "git"; name = "*";  run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
          ];

          prepend_preloaders = [
            # office plugin
            { mime = "application/openxmlformats-officedocument.*"; run = "office"; }
            { mime = "application/oasis.opendocument.*"; run = "office"; }
            { mime = "application/ms-*"; run = "office"; }
            { mime = "application/msword"; run = "office"; }
            { name = "*.docx"; run = "office"; }
          ];

          prepend_previewers = [
            # office plugin
            { mime = "application/openxmlformats-officedocument.*"; run = "office"; }
            { mime = "application/oasis.opendocument.*"; run = "office"; }
            { mime = "application/ms-*"; run = "office"; }
            { mime = "application/msword"; run = "office"; }
            { name = "*.docx"; run = "office"; }
          ];
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous file"; }
          { on = "i"; run = "arrow next"; desc = "Next file"; }

          { on = "n"; run = "leave"; desc = "Back to the parent directory"; }
          { on = "o"; run = "enter"; desc = "Enter the child directory"; }

          { on = "N"; run = "back";    desc = "Back to previous directory"; }
          { on = "O"; run = "forward"; desc = "Forward to next directory"; }

          { on = "R"; run = "seek -5"; desc = "Seek up 5 units in the preview"; }
          { on = "I"; run = "seek  5"; desc = "Seek down 5 units in the preview"; }

          { on = "j"; run = "find_arrow";            desc = "Next found"; }
          { on = "J"; run = "find_arrow --previous"; desc = "Previous found"; }

          { on = "e"; run = "open";               desc = "Open selected files"; }
          { on = "E"; run = "open --interactive"; desc = "Open selected files interactively"; }

          { on = "k"; run = "rename --cursor=before_ext"; desc = "Rename selected file(s)"; }

          # https://yazi-rs.github.io/docs/tips#dropping-to-shell
          { on = "!"; run = ''shell "$SHELL" --block''; desc = "Open $SHELL here"; }

          # https://yazi-rs.github.io/docs/tips#drag-and-drop
          { on = "<C-y>"; run = ''shell -- ${lib.getExe pkgs.dragon-drop} --and-exit --all --icon-only --on-top "$1"''; }

          # https://yazi-rs.github.io/docs/tips#selected-files-to-clipboard
          { on = "y"; run = [ ''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy --type text/uri-list'' "yank" ]; }

          # https://yazi-rs.github.io/docs/tips#cd-to-git-root
          { on = [ "g" "r" ]; run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"''; }

          { on = "T";     run = "plugin toggle-pane min-preview"; desc = "Show or hide the preview pane"; }
          { on = "<A-t>"; run = "plugin toggle-pane max-preview"; desc = "Maximize or restore the preview pane"; }

          { on = "R"; run = "plugin parent-arrow -1"; }
          { on = "I"; run = "plugin parent-arrow  1"; }

          { on = [ "z" "n" ]; run = "plugin time-travel --args=prev"; desc = "Go to previous snapshot"; }
          { on = [ "z" "o" ]; run = "plugin time-travel --args=next"; desc = "Go to next snapshot"; }
          { on = [ "z" "q" ]; run = "plugin time-travel --args=exit"; desc = "Exit browsing snapshots"; }

          { on = [ "g" "f" ]; run = "plugin jump-to-char"; desc = "Jump to char"; }

          { on = "<A-z>"; run  = "plugin zoom  1"; desc = "Zoom in hovered file"; }
          { on = "<A-Z>"; run  = "plugin zoom -1"; desc = "Zoom out hovered file"; }
        ];

        tasks.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous task"; }
          { on = "i"; run = "arrow next"; desc = "Next task"; }
        ];

        spot.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous line"; }
          { on = "i"; run = "arrow next"; desc = "Next line"; }
          { on = "n"; run = "swipe prev"; desc = "Swipe to previous file"; }
          { on = "o"; run = "swipe next"; desc = "Swipe to next file"; }
        ];

        pick.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous option"; }
          { on = "i"; run = "arrow next"; desc = "Next option"; }
        ];

        input.prepend_keymap = [
          { on = "h"; run = "insert";                       desc = "Enter insert mode"; }
          { on = "H"; run = [ "move first-char" "insert" ]; desc = "Move to the BOL, and enter insert mode"; }
          { on = "k"; run = "replace";                      desc = "Replace a single character"; }

          { on = "n"; run = "move -1"; desc = "Move back a character"; }
          { on = "o"; run = "move  1"; desc = "Move forward a character"; }
        ];

        confirm.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous line"; }
          { on = "i"; run = "arrow next"; desc = "Next line"; }
        ];

        cmp.prepend_keymap = [
          { on = "<A-r>"; run = "arrow prev"; desc = "Previous item"; }
          { on = "<A-i>"; run = "arrow next"; desc = "Next item"; }
        ];

        help.prepend_keymap = [
          { on = "r"; run = "arrow prev"; desc = "Previous line"; }
          { on = "i"; run = "arrow next"; desc = "Next line"; }
        ];
      };
    };
  };
}
