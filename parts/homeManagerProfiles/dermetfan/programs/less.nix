{
  home.sessionVariables.LESS = toString [
    "--RAW-CONTROL-CHARS"
    "--ignore-case"
    "--hilite-unread"
    "--shift .05"
    "--line-numbers"
    "--window -3"
    "--tabs 4"
  ];

  programs = {
    less = {
      enable = true;
      keys = ''
        #command
        i     forw-line
        I     forw-line-force
        r     back-line
        R     back-line-force
        n     left-scroll
        o     right-scroll
        j     repeat-search
        \ej   repeat-search-all
        J     reverse-search
        \eJ   reverse-search-all
        ^O^J  osc8-forw-search
        ^Oj   osc8-forw-search
      '';
    };

    lesspipe.enable = true;
  };
}
