{ config, lib,  ... }:

let
  cfg = config.profiles.dermetfan.services.parcellite;
in {
  options.profiles.dermetfan.services.parcellite.enable = lib.mkEnableOption "parcellite" // {
    default = config.services.parcellite.enable;
  };

  config.xdg.configFile."parcellite/parcelliterc".text = ''
    [rc]
    RCVersion=1
    use_copy=true
    use_primary=false
    synchronize=false
    save_history=true
    history_pos=false
    history_x=1
    history_y=1
    history_limit=25
    data_size=0
    item_size=5
    automatic_paste=false
    auto_key=false
    auto_mouse=true
    key_input=false
    restore_empty=true
    rc_edit=true
    type_search=true
    case_search=false
    ignore_whiteonly=false
    trim_wspace_begend=false
    trim_newline=false
    hyperlinks_only=false
    confirm_clear=true
    current_on_top=true
    single_line=false
    reverse_history=false
    item_length=50
    persistent_history=false
    persistent_separate=false
    persistent_on_top=false
    persistent_delim=\\n
    nonprint_disp=false
    ellipsize=2
    multi_user=true
    icon_name=parcellite
    menu_key=
    history_key=<Ctrl><Alt>H
    phistory_key=
    actions_key=
  '';
}
