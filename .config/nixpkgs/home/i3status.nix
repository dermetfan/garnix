{
  target = ".config/i3status/config";
  text = ''
    general {
        colors = true
        color_separator = "#55b5e7"
    }

    order += "disk /data/dermetfan"
    order += "disk /"
    #order += "ethernet _first_"
    #order += "wireless _first_"
    order += "cpu_temperature 0"
    order += "battery all"
    #order += "volume master"
    order += "time"

    time {
        format = "%m-%d %H:%M:%S "
    }

    volume master {}

    battery all {
        format = "%percentage %status %remaining %consumption"
        integer_battery_capacity = true
        low_threshold = 15
        threshold_type = time
    }

    cpu_temperature 0 {
        format = "CPU: %degrees°C"
        max_threshold = "90"
    }

    wireless _first_ {}

    ethernet _first_ {}

    disk "/data/dermetfan" {
        format = "data: %free (%percentage_used)"
        low_threshold = 10
        threshold_type = percentage_free
    }

    disk "/" {
        format = "%free (%percentage_used)"
        low_threshold = 25
        threshold_type = percentage_free
    }
  '';
}
