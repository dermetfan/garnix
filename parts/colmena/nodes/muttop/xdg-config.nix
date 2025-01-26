{ config, ... }:

{
  xdg.configFile = {
    "" = {
      source = ./xdg-config;
      recursive = true;
      force = true;
    };

    "lxqt/panel.conf" = {
      force = true;
      text = ''
        [desktopswitch]
        alignment=Right
        labelType=0
        rows=1
        showOnlyActive=true
        type=desktopswitch

        [fancymenu]
        alignment=Left
        favorites\1\desktopFile=/run/current-system/etc/profiles/per-user/${config.home.username}/share/applications/firefox.desktop
        favorites\2\desktopFile=/run/current-system/etc/profiles/per-user/${config.home.username}/share/applications/writer.desktop
        favorites\3\desktopFile=/run/current-system/etc/profiles/per-user/${config.home.username}/share/applications/simple-scan.desktop
        favorites\4\desktopFile=/run/current-system/etc/profiles/per-user/${config.home.username}/share/applications/qalculate-gtk.desktop
        favorites\size=4
        type=fancymenu

        [mount]
        alignment=Right
        type=mount

        [panel1]
        alignment=-1
        animation-duration=0
        background-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
        background-image=
        desktop=0
        font-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
        hidable=false
        hide-on-overlap=false
        iconSize=30
        lineCount=1
        lockPanel=true
        opacity=100
        panelSize=50
        plugins=fancymenu, desktopswitch, spacer2, taskbar, statusnotifier, tray, mount, volume, worldclock, showdesktop
        position=Left
        reserve-space=true
        show-delay=0
        visible-margin=true
        width=100
        width-percent=true

        [showdesktop]
        alignment=Right
        type=showdesktop

        [spacer2]
        alignment=Left
        expandable=true
        size=16
        spaceType=dotted
        type=spacer

        [statusnotifier]
        alignment=Right
        type=statusnotifier

        [taskbar]
        alignment=Left
        autoRotate=true
        buttonHeight=50
        buttonStyle=Icon
        buttonWidth=220
        closeOnMiddleClick=true
        groupingEnabled=true
        iconByClass=false
        raiseOnCurrentDesktop=true
        showDesktopNum=0
        showGroupOnHover=true
        showOnlyCurrentScreenTasks=false
        showOnlyMinimizedTasks=false
        showOnlyOneDesktopTasks=true
        type=taskbar
        ungroupedNextToExisting=false
        wheelDeltaThreshold=300
        wheelEventsAction=0

        [tray]
        alignment=Right
        type=tray

        [volume]
        alignment=Right
        type=volume

        [worldclock]
        alignment=Right
        autoRotate=false
        customFormat="'<b>'HH:mm:ss'</b><br/><font size=\"-2\">'ddd, d MMM yyyy'<br/>'TT'</font>'"
        dateFormatType=custom
        dateLongNames=false
        datePadDay=false
        datePosition=below
        dateShowDoW=false
        dateShowYear=false
        defaultTimeZone=
        formatType=custom-timeonly
        showDate=false
        showTimezone=false
        showTooltip=false
        showWeekNumber=true
        timeAMPM=false
        timePadHour=false
        timeShowSeconds=false
        timeZones\size=0
        timezoneFormatType=iana
        timezonePosition=below
        type=worldclock
        useAdvancedManualFormat=false
      '';
    };

    # Disable file locking because it does not work properly on a WebDAV share.
    # When opened via PCManFM-qt it opens files in read-only mode,
    # and when mounted via davfs2 it seems to straight up not save changes,
    # probably because it saves the changes somewhere else and fails to replace the file.
    # Maybe that would work better if we configured `use_locks = 0` for davfs2
    # but PCManFM-qt is preferred as it works better knowing the underlying filesystem is remote.
    "libreoffice/4/user/registrymodifications.xcu".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <item oor:path="/org.openoffice.Office.Common/Misc">
          <prop oor:name="UseDocumentSystemFileLocking" oor:op="fuse">
            <value>false</value>
          </prop>
        </item>
      </oor:items>
    '';
  };
}
