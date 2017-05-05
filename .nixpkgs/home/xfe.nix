{
  target = ".config/xfe/xferc";
  text = ''
    [OPTIONS]
    treepanel_tree_pct=0.2
    treetwopanels_lpanel_pct=0.4
    status=1
    twopanels_lpanel_pct=0.5
    folder_warn=1
    panel_view=0
    width=1920
    confirm_delete=1
    use_sudo=1
    use_trash_bypass=1
    confirm_overwrite=1
    paneltoolbar=1
    toolstoolbar=1
    confirm_delete_emptydir=1
    root_mode=1
    ask_before_copy=1
    mount_messages=1
    locationbar=1
    root_warn=0
    confirm_trash=1
    confirm_execute=1
    status=1
    generaltoolbar=1
    treetwopanels_tree_pct=0.2
    height=1062
    confirm_drag_and_drop=1

    [FILETYPES]
    zip=xarchiver,extract;Archive;;;;
    tar=xarchiver,extract;Archive;;;;
    mp4=smplayer,mplayer;Video;;;;
    md=geany;Document;;;;
    wmv=smplayer,mplayer;Video;;;;
    mp3=audacious,audacious,audacity;Audio;;;;
    pdf=zathura,xpdf;Document;;;;
    mov=smplayer,mplayer;Video;;;;
    m4a=audacious,audacious,audacity;Audio;;;;
    png=feh -FZ,feh -FZ,gimp;Image;;;;
    wma=audacious,mplayer,audacity;Audio;;;;
    java=geany,geany -r,geany;Source File;;;;
    jpg=feh -FZ,feh -FZ,gimp;Image;;;;
    avi=smplayer,mplayer;Video;;;;

    [HISTORY]
    run=

    [SETTINGS]
    smooth_scroll=1
    use_clearlooks=1
    show_pathlinker=1
    basecolor=#ede9e3
    relative_resize=0
    time_format=%x %X
    single_click=0
    tippause=500
    tiptime=10000
    wheellines=5
    file_tooltips=1

    [RIGHT PANEL]
    type_size=100
    deldate_size=150
    origpath_size=200
    liststyle=0
    attr_size=100
    size_size=60
    user_size=50
    dirs_first=1
    ext_size=100
    grou_size=50
    modd_size=150
    ignore_case=1
    sort_func=ascendingCase
    showthumbnails=0
    name_size=200
    hiddenfiles=0

    sort_func=ascendingCase
    find_ignorecase=1
    grep_ignorecase=0
    showthumbnails=0
    [DIR PANEL]
    hidden_dir=0
    sort_func=ascendingCase

    [PROGS]
    txteditor=geany
    imgviewer=feh -FZ
    videoviewer=smplayer
    xterm=lilyterm
    txtviewer=geany -r

    [LEFT PANEL]
    type_size=91
    deldate_size=150
    origpath_size=200
    liststyle=0
    attr_size=70
    size_size=105
    user_size=79
    dirs_first=1
    ext_size=71
    grou_size=61
    modd_size=171
    ignore_case=1
    sort_func=ascendingCase
    showthumbnails=0
    name_size=205
    hiddenfiles=0

    [FILEDIALOG]
    listmode=8388608
    type_size=100
    hiddenfiles=0
    thumbnails=0
    width=640
    attr_size=100
    user_size=50
    height=480
    ext_size=100
    grou_size=50
    modd_size=150
    name_size=200
    size_size=60

    [bookmarks]
    BOOKMARK1=/data/dermetfan
  '';
}
