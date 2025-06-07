{...}: {
  home.file.
    ".config/ags/user_options.jsonc".text =
    # ~/.config/ags/modules/.configuration/default_options.jsonc
    #jsonc
    ''{
          "animations": {
              "choreographyDelay": 35,
              "durationSmall": 110,
              "durationLarge": 180
          },
          "appearance": {
              "autoDarkMode": { // Turns on dark mode in certain hours. Time in 24h format
                  "enabled": false,
                  "from": "18:10",
                  "to": "6:10"
              },
              "borderless": false, // Uhm experimental...
              "keyboardUseFlag": false, // Use flag emoji instead of abbreviation letters
              "layerSmoke": false,
              "layerSmokeStrength": 0.2,
              "barRoundCorners": 1, // 0: No, 1: Yes
              "fakeScreenRounding": 2 // 0: None | 1: Always | 2: When not fullscreen
          },
          "apps": {
              "bluetooth": "blueberry",
              "imageViewer": "loupe",
              "network": "XDG_CURRENT_DESKTOP=\"gnome\" gnome-control-center wifi",
              "settings": "XDG_CURRENT_DESKTOP=\"gnome\" gnome-control-center",
              "taskManager": "gnome-usage",
              "terminal": "ghostty" // This is only for shell actions
          },
          "music": {
              "preferredPlayer": "plasma-browser-integration"
          },
          "sidebar": {
              "image": {
                  "columns": 2,
                  "batchCount": 20,
                  "allowNsfw": false
              },
              "pages": {
                  "order": [
                      "apis",
                      "tools"
                  ],
                  "defaultPage": "apis",
                  "apis": {
                      "order": [

                          "waifu",
                          "booru",
                          "gemini",
                          "gpt"
                      ],
                      "defaultPage": "gemini"
                  }
              },
              "quickToggles": {
                  "order": [
                      "wifi",
                      "bluetooth",
                      "nightlight",
                      "gamemode",
                      "idleinhibitor",
                      "cloudflarewarp"
                  ]
              },
              "calendar": {
                  "expandByDefault": true
              }
          },
          "search": {
              "enableFeatures": {
                  "actions": true,
                  "commands": true,
                  "mathResults": true,
                  "directorySearch": true,
                  "aiSearch": true,
                  "webSearch": true
              },
              "engineBaseUrl": "https://www.google.com/search?q=",
              "excludedSites": [
                  "quora.com"
              ]
          },
          "time": {
              // See https://docs.gtk.org/glib/method.DateTime.format.html
              // Here's the 12h format: "%I:%M%P"
              // For seconds, add "%S" and set interval to 1000
              "format": "%H:%M",
              "interval": 5000,
              "dateFormatLong": "%A, %d/%m", // On bar
              "dateInterval": 5000,
              "dateFormat": "%d/%m", // On notif time
              "calendarDateFormat": "%d %B %Y"
          },
          "weather": {
              "city": "",
              "preferredUnit": "C" // Either C or F
          },
          "workspaces": {
              "shown": 10
          },
          "dock": {
              "enabled": true,
              "hiddenThickness": 5,
              "pinnedApps": [
                  "librewolf"
              ],
              "layer": "top",
              "monitorExclusivity": true, // Dock will move to other monitor along with focus if enabled
              "searchPinnedAppIcons": false, // Try to search for the correct icon if the app class isn't an icon name
              "trigger": [
                  "client-added",
                  "client-removed"
              ], // client_added, client_move, workspace_active, client_active
              // Automatically hide dock after `interval` ms since trigger
              "autoHide": [
                  {
                      "trigger": "client-added",
                      "interval": 500
                  },
                  {
                      "trigger": "client-removed",
                      "interval": 500
                  }
              ]
          },
          // Longer stuff
          "icons": {
              // Find the window's icon by its class with levenshteinDistance
              // The file names are processed at startup, so if there
              // are too many files in the search path it'll affect performance
              // Example: ["/usr/share/icons/Tela-nord/scalable/apps"]
              "searchPaths": [
                  ""
              ],
              "symbolicIconTheme": {
                  "dark": "Adwaita",
                  "light": "Adwaita"
              },
              "substitutions": {
                  "code-url-handler": "visual-studio-code",
                  "Code": "visual-studio-code",
                  "GitHub Desktop": "github-desktop",
                  "Minecraft* 1.20.1": "minecraft",
                  "gnome-tweaks": "org.gnome.tweaks",
                  "pavucontrol-qt": "pavucontrol",
                  "wps": "wps-office2019-kprometheus",
                  "wpsoffice": "wps-office2019-kprometheus",
                  "footclient": "foot",
                  "": "image-missing"
              },
              "regexSubstitutions": [
                  {
                      "regex": "/^steam_app_(\\d+)$/",
                      "replace": "steam_icon_$1"
                  }
              ]
          },
      }
    '';
}
