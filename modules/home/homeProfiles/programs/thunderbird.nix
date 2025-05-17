{ lib, options, extraInputs, pkgs, ... }:
let
  inherit (extraInputs.nur.legacyPackages."${pkgs.system}".repos.rycee.firefox-addons)
    buildFirefoxXpiAddon british-english-dictionary-2 polish-dictionary;
  extensions = [
    british-english-dictionary-2
    polish-dictionary

    (buildFirefoxXpiAddon rec {
      pname = "thunderAI";
      version = "v2.2.0pre5";
      addonId = "thunderai@micz.it";
      url =
        "https://github.com/micz/ThunderAI/releases/download/v2.2.0pre5/thunderai-${version}.xpi";
      sha256 = "NSEMCAlVWH22sY0Z5zEYltrbU8CS1RdG5CXIxerpJh0=";
      meta = { };
    })
    (buildFirefoxXpiAddon rec {
      pname = "cardbook";
      version = "97.5";
      addonId = "cardbook@vigneau.philippe";
      url =
        "https://addons.thunderbird.net/user-media/addons/_attachments/634298/cardbook-${version}-tb.xpi";
      sha256 =
        "d2bef178398979d7e0e055b1259c59995302e4151bf471146073c1bbd88cc657";
      meta = with lib; {
        homepage = "https://gitlab.com/CardBook/CardBook";
        description =
          "This add-on allows you to manage all your contacts under the vCard standard.";
        license = licenses.mpl20;
        mozPermissions = [ ];
        platforms = platforms.all;
      };
    })
    (buildFirefoxXpiAddon rec {
      addonId = "quote_colors_collapse@thunderbird-mail.de";
      pname = "quote-colors-collapse";
      version = "4.2.4";
      url =
        "https://addons.thunderbird.net/user-media/addons/_attachments/987892/quote_colors_collapse-${version}-tb.xpi";
      sha256 =
        "0d3c31e5b57add80b00d2b93297154ea6b208e50bea7489d020946438d0e56db";
      meta = {

        homepage =
          "https://addons.thunderbird.net/thunderbird/addon/quotecolors/";
        mozPermissions = [

          "messagesRead"
          "messagesModify"
          "compose"
          "storage"
          "tabs"
        ];

      };
    })
    (buildFirefoxXpiAddon {
      pname = "languagetool";
      version = "8.11.2";
      addonId = "languagetool-mailextension@languagetool.org";
      url =
        "https://addons.thunderbird.net/thunderbird/downloads/file/1031394/grammatik_und_rechtschreibprufung_languagetool-8.11.2-tb.xpi";
      sha256 = "gBaKJIXjPtchXTNUKTRjD9iZ2OSqZGlw7xMjjsaK8rw=";
      meta = { };
    })
  ];
in {
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? "persistence") {
      persistence.state.directories = [ ".thunderbird" ];
    })
    {
      programs = {
        thunderbird = {
          settings = {
            "widget.wayland.use-move-to-rect" = false; # NOTE: workaround
            "mail.biff.show_tray_icon_always" = true;
            "mail.minimizeToTray" = true;
            "ldap_2.servers.outlook.dirType" = 3;
            "dom.security.unexpected_system_load_telemetry_enabled" = false;
            "network.trr.confirmation_telemetry_enabled" = false;
            "privacy.trackingprotection.origin_telemetry.enabled" = false;
            "telemetry.origin_telemetry_test_mode.enabled" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.ecosystemtelemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.shutdownPingSender.enabledFirstSession" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.rejected" = true;
            "toolkit.telemetry.prompted" = 2;
          };
          enable = true;
          # package = pkgs.betterbird;
          # package = pkgs.wrapThunderbird pkgs.thunderbird-unwrapped {
          #   extraPolicies = {
          #     DisableTelemetry = true;
          #     # add policies here...
          #
          #     # ---- EXTENSIONS ----
          #     ExtensionSettings = arr;
          #   };
          # };
          # inherit settings;

          profiles = {
            first = {
              inherit extensions;

              isDefault = true;
              withExternalGnupg = true;
              # extraConfig = ''
              #   user_pref("mail.html_compose", false);
              # '';
            };
          };
        };
      };
    }
  ];
}
