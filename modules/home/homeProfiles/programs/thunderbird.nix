{
  lib,
  options,
  config,
  pkgs,
  ...
}: let
  # file = ./mocha-mauve.xpi;
  thund = "https://addons.thunderbird.net/thunderbird/downloads/";
  arr = {
    "*".installation_mode = "blocked";
    # "{47f5c9df-1d03-5424-ae9e-0613b69a9d2f}" = {
    #   install_url = "file://${file}";
    #   installation_mode = "force_installed";
    # };
    "gmail-labels@itln.pl" = {
      installation_mode = "force_installed";
      install_url = "${thund}file/1031572/gmail_labels-0.3-tb.xpi";
    };
    "dkim_verifier@pl" = {
      installation_mode = "force_installed";
      install_url = "${thund}latest/dkim-verifier/addon-438634-latest.xpi";
    };
    "x0h44fx9x@relay.firefox.com" = {
      installation_mode = "force_installed";
      install_url = "${thund}latest/openpgp-alias-updater/addon-988108-latest.xpi";
    };
    "gconversation@xulforum.org" = {
      installation_mode = "force_installed";
      install_url = "${thund}file/1028919/thunderbird_conversations-4.1.7-tb.xpi";
    };
    # "admin@fastaddons.com_Darko" = {
    #   installation_mode = "force_installed";
    #   install_url = "${thund}latest/darko_t/addon-987944-latest.xpi";
    # };
  };
in {
  config = lib.mkMerge [
    (
      lib.optionalAttrs (options ? "persistence")
      {
        persistence.state.directories = [
          ".thunderbird"
        ];
      }
    )
    {
      accounts.email.accounts.gmailmain.thunderbird = {
        enable = true;
        profiles = ["first"];
        settings = id: {
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.server.server_${id}.authMethod" = 10;
          # "mail.openpgp.alias_rules_file" = "openpgp_alias.json";
          # "mail.openpgp.alias_rules_file" = "file://${alias-rules-file}";
          "mail.openpgp.fetch_pubkeys_from_gnupg" = true;
        };
      };
      programs = {
        thunderbird = {
          enable = true;
          # package = pkgs.betterbird;
          package = pkgs.wrapThunderbird pkgs.thunderbird-unwrapped {
            extraPolicies = {
              DisableTelemetry = true;
              # add policies here...

              # ---- EXTENSIONS ----
              ExtensionSettings = arr;
            };
          };
          # inherit settings;

          profiles = {
            first = {
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
