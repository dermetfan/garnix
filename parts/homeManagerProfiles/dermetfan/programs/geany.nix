{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.programs.geany;
in {
  options.profiles.dermetfan.programs.geany.enable = lib.mkEnableOption "Geany" // {
    default = config.programs.geany.enable or false;
  };

  config.xdg.configFile = {
    "geany/keybindings.conf".text = ''
      [Bindings]
      menu_new=<Primary>n
      menu_open=<Primary>o
      menu_open_selected=<Primary><Shift>o
      menu_save=<Primary>s
      menu_saveas=
      menu_saveall=<Primary><Shift>s
      menu_print=<Primary>p
      menu_close=<Primary>w
      menu_closeall=<Primary><Shift>w
      menu_reloadfile=F5
      file_openlasttab=<Primary><Shift>t
      menu_quit=<Primary>q
      menu_undo=<Primary>z
      menu_redo=<Primary><Shift>z
      edit_duplicateline=<Primary>d
      edit_deleteline=<Primary>y
      edit_deletelinetoend=<Shift>Delete
      edit_transposeline=
      edit_scrolltoline=<Primary><Shift>l
      edit_scrolllineup=<Alt>Up
      edit_scrolllinedown=<Alt>Down
      edit_completesnippet=Tab
      move_snippetnextcursor=
      edit_suppresssnippetcompletion=
      popup_contextaction=
      edit_autocomplete=<Primary>space
      edit_calltip=<Primary><Shift>space
      edit_macrolist=<Primary>Return
      edit_wordpartcompletion=Tab
      edit_movelineup=<Shift><Alt>Up
      edit_movelinedown=<Shift><Alt>Down
      menu_cut=<Primary>x
      menu_copy=<Primary>c
      menu_paste=<Primary>v
      edit_copyline=<Primary><Shift>c
      edit_cutline=<Primary><Shift>x
      menu_selectall=<Primary>a
      edit_selectword=<Shift><Alt>w
      edit_selectline=<Shift><Alt>l
      edit_selectparagraph=<Shift><Alt>p
      edit_selectwordpartleft=
      edit_selectwordpartright=
      edit_togglecase=<Primary><Alt>u
      edit_commentlinetoggle=<Primary>e
      edit_commentline=<Primary>KP_Divide
      edit_uncommentline=<Primary><Shift>KP_Divide
      edit_increaseindent=
      edit_decreaseindent=
      edit_increaseindentbyspace=
      edit_decreaseindentbyspace=
      edit_autoindent=
      edit_sendtocmd1=<Primary>1
      edit_sendtocmd2=<Primary>2
      edit_sendtocmd3=<Primary>3
      edit_sendtovte=
      format_reflowparagraph=<Primary>j
      edit_joinlines=
      menu_insert_date=<Shift><Alt>d
      edit_insertwhitespace=
      edit_insertlinebefore=
      edit_insertlineafter=<Shift>Return
      menu_preferences=<Primary><Alt>p
      menu_pluginpreferences=
      menu_find=<Primary>f
      menu_findnext=<Primary>g
      menu_findprevious=<Primary><Shift>g
      menu_findnextsel=
      menu_findprevsel=
      menu_replace=<Primary>h
      menu_findinfiles=<Primary><Shift>f
      menu_nextmessage=
      menu_previousmessage=
      popup_findusage=<Primary><Shift>e
      popup_finddocumentusage=
      find_markall=<Primary><Shift>m
      nav_back=<Alt>Left
      nav_forward=<Alt>Right
      menu_gotoline=<Primary>l
      edit_gotomatchingbrace=<Primary>b
      edit_togglemarker=<Primary>m
      edit_gotonextmarker=<Primary>period
      edit_gotopreviousmarker=<Primary>comma
      popup_gototagdefinition=<Primary>t
      popup_gototagdeclaration=<Primary><Shift>b
      edit_gotolinestart=Home
      edit_gotolineend=End
      edit_gotolinestartvisual=<Alt>Home
      edit_gotolineendvisual=<Alt>End
      edit_prevwordstart=<Primary>slash
      edit_nextwordstart=<Primary>backslash
      menu_toggleall=
      menu_fullscreen=F11
      menu_messagewindow=F3
      toggle_sidebar=F4
      menu_zoomin=<Primary>equal
      menu_zoomout=<Primary>minus
      normal_size=<Primary>0
      menu_linewrap=
      menu_linebreak=
      menu_clone=
      menu_replacetabs=
      menu_replacespaces=
      menu_togglefold=
      menu_foldall=
      menu_unfoldall=
      reloadtaglist=<Primary><Shift>r
      remove_markers=
      remove_error_indicators=
      remove_markers_and_indicators=
      project_new=
      project_open=
      project_properties=
      project_close=
      build_compile=F8
      build_link=F9
      build_make=<Shift>F9
      build_makeowntarget=<Primary><Shift>F9
      build_makeobject=<Shift>F8
      build_nexterror=
      build_previouserror=
      build_run=
      build_options=
      menu_opencolorchooser=
      menu_help=F1
      switch_editor=F2
      switch_search_bar=F7
      switch_message_window=
      switch_compiler=
      switch_messages=
      switch_scribble=F6
      switch_vte=
      switch_sidebar=
      switch_sidebar_symbol_list=
      switch_sidebar_doc_list=
      switch_tableft=<Primary>Page_Up
      switch_tabright=<Primary>Page_Down
      switch_tablastused=<Primary>Tab
      move_tableft=<Primary><Shift>Page_Up
      move_tabright=<Primary><Shift>Page_Down
      move_tabfirst=
      move_tablast=
      file_properties=
      edit_deletelinetobegin=<Primary><Shift>BackSpace
      edit_sendtocmd4=
      edit_sendtocmd5=
      edit_sendtocmd6=
      edit_sendtocmd7=
      edit_sendtocmd8=
      edit_sendtocmd9=

      [html_chars]
      insert_html_chars=
      replace_special_characters=
      htmltoogle_toggle_plugin_status=

      [file_browser]
      focus_file_list=
      focus_path_entry=

      [split_window]
      split_horizontal=
      split_vertical=
      split_unsplit=
    '';

    "geany/plugins/filebrowser/filebrowser.conf".text = ''
      [filebrowser]
      open_command=xfe "%d"
      show_hidden_files=false
      hide_object_files=true
      hidden_file_extensions=.o .obj .so .dll .a .lib .pyc
      fb_follow_path=true
      fb_set_project_base_path=true
    '';

    "geany/colorschemes".source = pkgs.fetchFromGitHub {
      owner = "RobLoach";
      repo = "base16-geany";
      rev = "40fc74c52ddec7efddbeff8a9b7b25652e7b45f6";
      sha256 = "1jka7raxrzhdkd6jpwxn0k118cma65pfja7zcl0kb2p6fvj7sy3q";
    };
  };
}
