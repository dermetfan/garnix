{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.kakoune;
in {
  options.config.programs.kakoune.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.kakoune.enable;
    defaultText = "<option>config.programs.kakoune.enable</option>";
    description = "Whether to configure kakoune.";
  };

  config.programs.kakoune.config = lib.mkIf cfg.enable {
    colorScheme = "gruvbox";
    alignWithTabs = true;
    indentWidth = 0;
    numberLines = {
      enable = true;
      highlightCursor = true;
    };
    showMatching = true;
    showWhitespace = {
      enable = true;
      nonBreakingSpace = "⍽";
      tab = "→";
      space = "\\ ";
      lineFeed = "\\ ";
    };
    tabStop = 4;
    wrapLines = {
      enable = true;
      indent = true;
      word = true;
    };
    ui = {
      assistant = "cat";
      statusLine = "top";
      enableMouse = true;
      setTitle = true;
    };
    keyMappings = [
      {
        docstring = "case insensitive search";
        mode = "user";
        key = "/";
        effect = "/(?i)";
      }
      {
        docstring = "case insensitive backward search";
        mode = "user";
        key = "<a-/>";
        effect = "<a-/>(?i)";
      }
      {
        docstring = "case insensitive extend search";
        mode = "user";
        key = "?";
        effect = "?(?i)";
      }
      {
        docstring = "case insensitive backward extend search";
        mode = "user";
        key = "<a-?>";
        effect = "<a-?>(?i)";
      }
    ];
  };
}
