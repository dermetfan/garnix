{
  target = ".config/beets/config.yaml";
  text = let
    dir = let
      data = /data/dermetfan;
    in "${if builtins.pathExists data then builtins.toString data else "~"}/audio/music/library";
  in ''
    directory: ${dir}
    library: ${dir}/beets.db
    import:
      move: yes
    plugins:
      - fromfilename
      - discogs
      - duplicates
      - edit
      - fetchart
      - ftintitle
      - fuzzy
      - info
      - lastgenre
      - lyrics
      - mbsubmit
      - mbsync
      - missing
      - play
      - random
      - web
    play:
      command: audacious
      raw: yes
  '';
}
