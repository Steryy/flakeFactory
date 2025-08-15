{
  # "browser.newtabpage.activity-stream.floorp.background.image.path"= 	;
  # "browser.newtabpage.activity-stream.floorp.background.images.extensions"= png,jpg,jpeg,webp,gif,svg,tiff,tif,bmp,avif,jxl	;
  # "browser.newtabpage.activity-stream.floorp.background.images.folder"= 	;
  # "browser.newtabpage.activity-stream.floorp.background.type" = 1;
  # "browser.newtabpage.activity-stream.floorp.newtab.backdrop.blur.disable" = false;
  # "browser.newtabpage.activity-stream.floorp.newtab.imagecredit.hide" = false;
  # "browser.newtabpage.activity-stream.floorp.newtab.releasenote.hide" = false;
  "enable.floorp.update" = true;
  "enable.floorp.updater.latest" = false;
  # "floorp.bookmarks.bar.focus.mode" = false;
  # "floorp.browser.floorpSearch.enabled" = false;
  # "floorp.browser.native.downloadbar.enabled" = false;
  # "floorp.browser.native.verticaltabs.enabled" = false;
  # "floorp.browser.nora.csk.data" = {};
  # "floorp.browser.note.backup.latest.time" = 1741280536814;
  "floorp.browser.note.enabled" = false;
  # "floorp.browser.note.memos"= {"titles":["Welcome!"],"contents":["Welcome to Floorp Notes! Here are some instructions on how to use it!\n\nFloorp Notes is a notepad that lets you store multiple notes that sync across devices. To enable synchronization, you need to sign in to Floorp with your Firefox account.\nFloorp Notes will be saved in your Floorp settings and synchronized across devices using Firefox Sync. Firefox Sync encrypts the contents of the sync with your Firefox account password, so no one but you know its contents."]}	;
  "floorp.browser.note.memos.using" = 0;
  "floorp.browser.profile-manager.enabled" = false;
  "floorp.browser.sidebar.enable" = true;
  "floorp.browser.sidebar.is.displayed" = false;
  "floorp.browser.sidebar.right" = false;
  "floorp.browser.sidebar.useIconProvider" = "duckduckgo";
  "floorp.browser.sidebar2.data" = builtins.replaceStrings [ "\n" ] [
    " "
  ]
  #json
    ''

      {
        "data": {
          "floorp__bmt": {
            "url": "floorp//bmt",
            "width": 600
          },
          "floorp__bookmarks": {
            "url": "floorp//bookmarks",
            "width": 415
          },
          "floorp__history": {
            "url": "floorp//history",
            "width": 415
          },
          "floorp__downloads": {
            "url": "floorp//downloads",
            "width": 415
          },
          "floorp__notes": {
            "url": "floorp//notes",
            "width": 550
          }
        },
        "index": [
          "floorp__bmt",
          "floorp__bookmarks",
          "floorp__history",
          "floorp__downloads"
        ]
      }
    '';
  # "floorp.browser.sidebar2.global.webpanel.width" = 400;
  # "floorp.browser.sidebar2.hide.to.unload.panel.enabled" = false;
  # "floorp.browser.splitView.width" = 0;
  # "floorp.browser.splitView.working" = false;
  # "floorp.browser.ssb.enabled" = false;
  # "floorp.browser.tabbar.multirow.max.enabled" = true;
  # "floorp.browser.tabbar.multirow.max.row" = 3;
  # "floorp.browser.tabbar.multirow.newtab-inside.enabled" = false;
  # "floorp.browser.tabbar.settings" = 0;
  # "floorp.browser.tabs.openNewTabPosition" = -1;
  # "floorp.browser.tabs.tabMinHeight" = 30;
  # "floorp.browser.tabs.verticaltab" = false;
  # "floorp.browser.tabs.verticaltab.right" = false;
  # "floorp.browser.tabs.verticaltab.temporary.disabled" = false;
  # "floorp.browser.tabs.verticaltab.width" = 200;
  # "floorp.browser.user.interface" = 3;
  # # "floorp.browser.workspace.all"= 	;
  # "floorp.browser.workspace.backuped" = false;
  # "floorp.browser.workspace.changeWorkspaceWithDefaultKey" = true;
  # "floorp.browser.workspace.closePopupAfterClick" = false;
  # "floorp.browser.workspace.container.userContextId" = 0;
  # # "floorp.browser.workspace.current"= 	;
  # "floorp.browser.workspace.info" = [];
  # "floorp.browser.workspace.manageOnBMS" = false;
  # "floorp.browser.workspace.showWorkspaceName" = true;
  # "floorp.browser.workspace.tab.enabled" = true;
  # "floorp.browser.workspace.tabs.state" = [];
  # "floorp.browser.workspaces.disabledBySystem" = true;
  # "floorp.browser.workspaces.enabled" = true;
  # "floorp.chrome.theme.mode" = -1;
  # "floorp.custom.shortcutkeysAndActions"= [{"actionName":"togglePanel","key":"","keyCode":"VK_F2","modifiers":""}]	;
  # "floorp.custom.shortcutkeysAndActions.customAction1"= 	;
  # "floorp.custom.shortcutkeysAndActions.customAction2"= 	;
  # "floorp.custom.shortcutkeysAndActions.customAction3"= 	;
  # "floorp.custom.shortcutkeysAndActions.customAction4"= 	;
  # "floorp.custom.shortcutkeysAndActions.customAction5"= 	;
  # "floorp.custom.shortcutkeysAndActions.enabled" = true;
  # "floorp.custom.shortcutkeysAndActions.remove.fx.actions" = false;
  # "floorp.delete.browser.border" = false;
  # "floorp.disable.fullscreen.notification" = false;
  # "floorp.download.notification" = 4;
  # "floorp.dualtheme.theme" = [];
  # "floorp.enable.auto.restart" = false;
  # "floorp.enable.dualtheme" = false;
  # "floorp.enable.multitab" = false;
  # "floorp.extensions.allowPrivateBrowsingByDefault.is.enabled" = false;
  # "floorp.extensions.webextensions.sidebar-action"= {"data":{"tridactyl.vim@cmcaine.co.uk":{"title":"Tridactyl sidebar","panel":"moz-extension://5a732a70-e54b-4289-97e0-44c3edcf9b99/static/newtab.html","icon":"moz-extension://5a732a70-e54b-4289-97e0-44c3edcf9b99/static/logo/Tridactyl_150px.png"},"{446900e4-71c2-419f-a6a7-df9c091e268b}":{"title":"Bitwarden","panel":"moz-extension://881690c0-3a62-42ac-97a3-359f5bfba98b/popup/index.html?uilocation=sidebar","icon":"moz-extension://881690c0-3a62-42ac-97a3-359f5bfba98b/images/icon19.png"}}}	;
  # "floorp.lepton.interface" = 2;
  # "floorp.multitab.bottommode" = false;
  # "floorp.navbar.bottom" = false;
  # "floorp.newtab.overrides.newtaburl"= 	;
  # "floorp.openLinkInExternal.browserId"= 	;
  # "floorp.openLinkInExternal.enabled" = false;
  # "floorp.startup.homepage_override_url.ja"= https://blog.ablaze.one/category/ablaze/ablaze-project/floorp/#ja	;
  # "floorp.startup.oldVersion"= 11.23.0	;
  # "floorp.tabbar.style" = 0;
  # "floorp.tabs.showPinnedTabsTitle" = false;
  # "floorp.tabscroll.reverse" = false;
  # "floorp.tabscroll.wrap" = false;
  # "floorp.tabsleep.enabled" = false;
  # "floorp.tabsleep.tabTimeoutMinutes" = 115;
  # "floorp.titlebar.favicon.color" = false;
  # # "floorp.user.js.customize"= 	;
  # "floorp.verticaltab.hover.enabled" = false;
  # "floorp.verticaltab.paddingtop.enabled" = false;
  # "floorp.verticaltab.show.newtab.button" = false;
  # "floorp.webcompat.enabled" = true;
  # "services.sync.prefs.sync.floorp.browser.note.memos" = true;
  # "services.sync.prefs.sync.floorp.browser.sidebar.right" = true;
  # "services.sync.prefs.sync.floorp.browser.user.interface" = true;
  # "services.sync.prefs.sync.floorp.optimized.verticaltab" = true;
}
