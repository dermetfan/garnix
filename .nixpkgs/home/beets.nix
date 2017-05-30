{
  target = ".config/beets/config.yaml";
  text = let
    dir = if builtins.pathExists /data/dermetfan then
      "/data/dermetfan/audio/music" else "~/audio/music";
  in ''
    directory: ${dir}
    library: ${dir}/beets.db
    import:
      move: yes
    plugins:
      - fromfilename
  '';
}
