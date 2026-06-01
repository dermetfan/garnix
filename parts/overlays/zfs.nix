_:

final: prev: {
  zfs-holds = prev.writers.writeNuBin "zfs-holds" ''
    # Lists all holds in all snapshots.
    # Does not ship with zfs userspace utils.
    def main [
      --json (-j)          # JSON output with unix-seconds timestamps.
      --recursive (-r)
      ...datasets: string
    ]: [
      nothing -> table<
        snapshot: string
        tag: string
        timestamp: datetime
      >
    ] {
      (
        zfs holds
        -Hp
        ...(if $recursive {[-r]} else {[]})
        ...(
          (
            zfs list
            -t snapshot
            --json --json-int
            ...(if $recursive {[-r]} else {[]})
            ...$datasets
          )
          | from json
          | get datasets
          | columns
        )
      )
      | parse "{snapshot}\t{tag}\t{timestamp}"
      | if $json {
        to json
      } else {
        into datetime --format %s timestamp
      }
    }
  '';
}
