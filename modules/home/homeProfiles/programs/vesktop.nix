{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge [
    (
      lib.optionalAttrs (! (options.programs ? "nixcord") && options ? "stylix") {
        stylix.targets.vesktop.enable = true;
      }
    )
    (
      lib.optionalAttrs (! (options.programs ? "nixcord")) {
        home.packages = with pkgs; [
          vesktop
        ];
      }
    )
    (
      lib.optionalAttrs (options.programs ? "nixcord")
      {
        xdg.userDirs.extraConfig = {
          VESKTOP_CONF = ".config/vesktop";
        };
        programs.nixcord = {
          enable = true; # enable Nixcord. Also installs discord package
          vesktop = {enable = true;};
          discord.enable = false;
          # quickCss = "some CSS"; # quickCSS file
          config = {
            # ];
            frameless = true; # set some Vencord options
            plugins = {
              hideAttachments.enable = true; # Enable a Vencord plugin
              reverseImageSearch.enable = true;
              shikiCodeblocks = {enable = true;};
              silentTyping.enable = true;
              USRBG.enable = true;
              validReply.enable = true;
              validUser.enable = true;
              viewIcons.enable = true;
              youtubeAdblock.enable = true;
              anonymiseFileNames.enable = true;
              betterSettings.enable = true;
              copyEmojiMarkdown.enable = true;
              copyUserURLs.enable = true;
              # decor.enable = true;
              fakeNitro = {
                enable = true;
                emojiSize = 128;
              };
              fixYoutubeEmbeds.enable = true;
              iLoveSpam.enable = true;
              memberCount.enable = true;
              moreCommands.enable = true;
              moreKaomoji.enable = true;
              newGuildSettings = {enable = true;};
              noBlockedMessages.enable = true;
              noTypingAnimation.enable = true;
              nsfwGateBypass.enable = true;
              permissionsViewer.enable = true;
              relationshipNotifier.enable = true;
              messageLogger = {
                enable = true;
                ignoreBots = true;
                collapseDeleted = true;
              };
              biggerStreamPreview.enable = true;
              clearURLs.enable = true;
              betterGifPicker.enable = true;
              betterFolders = {
                enable = true;
                sidebarAnim = false;
              };
              # ignoreActivities = {
              #   # Enable a plugin and set some options
              #   enable = true;
              #   ignorePlaying = true;
              #   ignoreWatching = true;
              #   # ignoredActivities = ["someActivity"];
              # };
            };
          };
          extraConfig = {
            # Some extra JSON config here
            # ...
          };
        };
      }
    )
  ];
  # home.packages = with pkgs; [
  #   vesktop
  # ];
}
