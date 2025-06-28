{
  "extensions.autoDisableScopes" = 0;
  "services.sync.engine.passwords" = false;
  "widget.use-xdg-desktop-portal.file-picker" = 1;
  "widget.use-xdg-desktop-portal.mime-handler" = 1;
  "widget.use-xdg-desktop-portal.location" = 1;
  "widget.use-xdg-desktop-portal.open-uri" = 1;
  "browser.startup.page" = 3; # Resume previous session on startup
  # "browser.aboutConfig.showWarning" = false; # I sometimes know what I'm doing
  # "browser.ctrlTab.sortByRecentlyUsed" = false; # (default) Who wants that?
  # "browser.download.useDownloadDir" = false; # Ask where to save stuff
  # "browser.translations.neverTranslateLanguages" = "de"; # No need :)
  "privacy.clearOnShutdown.history" = false; # We want to save history on exit
  # Hi-DPI
  # "layout.css.devPixelsPerPx" = "1.5";
  # Allow executing JS in the dev console
  "devtools.chrome.enabled" = true;
  # Disable browser crash reporting
  "browser.tabs.crashReporting.sendReport" = false;
  # Allow userCrome.css
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  # Why the fuck can my search window make bell sounds
  "accessibility.typeaheadfind.enablesound" = false;
  # Why the fuck can my search window make bell sounds
  "general.autoScroll" = true;

  # Hardware acceleration
  # See https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#firefox
  # "gfx.webrender.all" = true;
  # "media.ffmpeg.vaapi.enabled" = true;
  # "media.rdd-ffmpeg.enabled" = true;
  # "widget.dmabuf.force-enabled" = true;
  # # "media.av1.enabled" = false; # XXX: change once I've upgraded my GPU
  # # XXX: what is this?
  # "media.ffvpx.enabled" = false;
  # "media.rdd-vpx.enabled" = false;
  #
  # # Privacy
  # "privacy.donottrackheader.enabled" = true;
  # "privacy.trackingprotection.enabled" = true;
  # "privacy.trackingprotection.socialtracking.enabled" = true;
  "privacy.userContext.enabled" = true;
  "privacy.userContext.ui.enabled" = true;

  "browser.send_pings" = false; # (default) Don't respect <a ping=...>

  # This allows firefox devs changing options for a small amount of users to test out stuff.
  # Not with me please ...
  "app.normandy.enabled" = false;
  "app.shield.optoutstudies.enabled" = false;

  "beacon.enabled" = false; # No bluetooth location BS in my webbrowser please
  "device.sensors.enabled" = false; # This isn't a phone
  "geo.enabled" = false; # Disable geolocation alltogether

  # ESNI is deprecated ECH is recommended
  "network.dns.echconfig.enabled" = true;

  # Disable telemetry for privacy reasons
  "toolkit.telemetry.archive.enabled" = false;
  "toolkit.telemetry.enabled" = false; # enforced by nixos
  "toolkit.telemetry.server" = "";
  "toolkit.telemetry.unified" = false;
  "extensions.webcompat-reporter.enabled" =
    false; # don't report compability problems to mozilla
  "datareporting.policy.dataSubmissionEnabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "browser.ping-centre.telemetry" = false;
  "browser.urlbar.eventTelemetry.enabled" = false; # (default)

  # Disable some useless stuff
  "extensions.pocket.enabled" = false; # disable pocket, save links, send tabs
  "extensions.abuseReport.enabled" =
    false; # don't show 'report abuse' in extensions
  "extensions.formautofill.creditCards.enabled" =
    false; # don't auto-fill credit card information
  "identity.fxaccounts.enabled" = false; # disable firefox login
  "identity.fxaccounts.toolbar.enabled" = false;
  "identity.fxaccounts.pairing.enabled" = false;
  "identity.fxaccounts.commands.enabled" = false;
  "browser.contentblocking.report.lockwise.enabled" =
    false; # don't use firefox password manger
  "browser.uitour.enabled" = false; # no tutorial please
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

  # disable EME encrypted media extension (Providers can get DRM
  # through this if they include a decryption black-box program)
  "browser.eme.ui.enabled" = false;
  "media.eme.enabled" = false;

  # don't predict network requests
  "network.predictor.enabled" = false;
  "browser.urlbar.speculativeConnect.enabled" = false;

  # disable annoying web features
  # "dom.push.enabled" = false; # no notifications, really...
  # "dom.push.connection.enabled" = false;
  # "dom.battery.enabled" = false; # you don't need to see my battery...
  # "dom.private-attribution.submission.enabled" = false; # No PPA for me pls
}
