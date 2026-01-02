{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  loader = "fabric";
  version = "1.21.11";

  getMc = lodaer: version:
    pkgs."${loader}Servers"."${loader}-${lib.replaceStrings ["."] ["_"] version}";
  packages = import ./packages.nix {inherit (pkgs) fetchurl;};
  getFromPackages = path: [
    (lib.filter (x: packages ? "${x}"))
    (map (x: let
      p = packages."${x}";
    in {
      name = "${path}/${p.name}";
      value = p;
    }))
    lib.listToAttrs
  ];
in {
  imports = [
    inputs.
        nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [inputs.nix-minecraft.overlay];
  networking.firewall.allowedTCPPorts = [8100];
  networking.firewall.allowedUDPPorts = [25565 19132];
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers."newEnd" = {
      enable = true;
      # jvmOpts = "-Xms16896M -Xmx16896M    -XX:ParallelGCThreads=16  -XX:ConcGCThreads=16 ";
      # jvmOpts = " -Xms16896M -Xmx16896M";
      jvmOpts = "-Xmx10G -Xms8G";
      managementSystem = {
        tmux.enable = false;
        systemd-socket.enable = true;
      };
      path = with pkgs; [
        config.programs.git.package
        config.programs.git.lfs.package
      ];

      # dataDir = "/var/lib/minecraft-troon";

      serverProperties = {
        gamemode = "survival";
        difficulty = "hard";
        simulation-distance = 5;
        motd = ''Polymerised McServer\u00A7r\n                 \u00A73blahaj included'';
        spawn-protection = 0;
        white-list = true;
        level-seed = -7543370364039632293;
        # enforce-whitelist=false
        # enable-command-block = true;
        # enforce-secure-profile = false;
        # level-type = "minecraft:amplified";

        # "chunky.maxWorkingCount" = 80;
        # "plugin-remapping" = false;
      };
      # whitelist = {
      #   SterYYY = ""
      #
      # };
      operators = {
        SterYYY = {
          uuid = "7fe1105b-1f99-45e8-b4c1-3141e30e9f15";
          level = 4;
          bypassesPlayerLimit = true;
        };
      };
      files = {
        "config/polymer/auto-host.json".value = {
          #"Enables Polymer's ResourcePack Auto Hosting";
          enabled = true;
          #"Marks resource pack as required";
          required = false;
          #"Mods may override the above setting and make the resource pack required; set this to false to disable that.",
          mod_override = true;
          #"Type of resource pack provider. Default: 'polymer:automatic'";
          type = "polymer:automatic";
          #"Configuration of type; see provider's source for more details",
          settings = {
            forced_address = "";
          };
          #"Message sent to clients before pack is loaded";
          message = "This server uses resource pack to enhance gameplay with custom textures and models. It might be unplayable without them.";
          #"Disconnect message in case of failure";
          disconnect_message = "Couldn't apply server resourcepack!";
          #"Allows to define more external resource packs. It's an object with 'id' for uuid; 'url' for the pack url and 'hash' for the SHA1 hash.",
          external_resource_packs = [];
          #"Moves resource pack generation earlier when running on server. Might break some mods.";
          setup_early = false;
          # "Enables dialog infobox when resource pack isn't ready.";
          resource_pack_status_dialog = true;
          # "Enables dialog infobox when resource pack isn't ready.";
          dialog_title = "The server's resource pack is still generating!";
          # "Default body text before status is ready (or when it's disabled).";
          dialog_default_body = "Waiting...";
          # "Text below name with some extra information about resource pack generation";
          dialog_body_header = "This server requires a resource pack; which hasn't finished generating yet...\nIt might take a while for it to finish!";
          # "Enables displaying internal resource pack generation status.";
          dialog_show_status = true;
          # "Enables displaying 'dots' indicating that work is being done!";
          dialog_show_dots = true;
          # "Clears all client-side resourcepacks before sending Autohost handled ones.";
          clear_all_client_resource_packs = false;
          # "Adds hash to name of resource pack file served with web server";
          include_hash_in_name = true;
          # "Value of Cache-Control max age header";
          cache_control_max_age = 31536000;
          # "Delays server from showing as online on player list until resource pack is generated.";
          delay_player_list_motd_until_generated = false;
        };
        "config/polymer/resource-pack.json".value = {
          # "UUID of default/main resource pack.";
          main_uuid = "79ad9f2c-ba34-4a07-bc38-ad9b3918f6df";
          #Marks resource pack as required; only effects clients and mods using api to check it";
          markResourcePackAsRequiredByDefault = false;
          #"Included resource packs from mods!";
          include_mod_assets = [];
          #"Included resource packs from zips!";
          include_zips = [
            "world/datapacks/woodland.zip"
            (packages."res-just-atlas")
            # ./external/justResource.zip
          ];
          #"Path used for creation of default resourcepack!";
          resource_pack_location = "polymer/resource_pack.zip";
          #"Prevents selected paths from being added to resource pack; if they start with provided text.";
          prevent_path_with = [];
          #"Removes the incompatibility warning on the default pack; by marking it as compatible with everything.";
          ignore_pack_version = false;
          # "Toggles logging of non-critical errors when generating the pack.";
          "log_errors" = true;
        };
      };
      package =
        getMc loader version;

      symlinks =
        (
          lib.mapAttrs' (n: v: {
            name = "world/datapacks/${n}";
            value = v;
          })
          {
            "blahaj.zip" = ./external/blahaj.zip;
            "woodland.zip" = ./external/woodland.zip;

            "avartified.zip" = ./external/v10qraftyfied.zip;
            "illager-exp.zip" = ./external/illager-expansion.zip;
          }
        )
        // (
          lib.pipe ["alien-end" "just-atlas"]
          (
            getFromPackages "world/datapacks"
          )
        )
        // {
          "allowed_symlinks.txt" = pkgs.writeText "allowed_symlinks.txt" "/nix/store";
        }
        // (
          lib.pipe (
            lib.optionals (loader == "fabric") (
              [
                "dungeons-and-taverns-ocean-monument-overhaul"
                "dungeons-and-taverns-pillager-outpost-overhaul"
                "terralith"
                "trimmable-tools"
                # "alien-end"
                "amplified-nether"
                # "just-atlas"
                "map-change"
                "tectonic"
                # "bundled_"
                # TODO: install
                "better-nether-map"
              ]
              ++
              # polymer
              [
                # "goml-reserved"
                # "universal-graves"
                # "sswaystones"
                # "enderscape-polymer"
                "polyfactory"
                "illager-expansion-polymer"
                # "gone-fishing"
                "filament"
                # "tsa-planks"
                # "tsa-stone"
                "polydex"
                "polymer"
                "trinkets-polymer"
                "polymer-patch-bundle"
                # "serverbacksnow"
                # "lootr-polymer-patch"
              ]
              ++ [
                # TODO: install
                "crowmap"
                "cinderscapes"
                "terrestria"
                "traverse"
                "blockus"
                # "enderscape"
                "servercore"
                # "danse"
                # "yacl"
                # "bubble-column-tweaks"
                # "lootr"
                "alternate-current"
                "cloth-config"
                "placeholder-api"
                "distanthorizons"
                # "easyauth"
                # "essential-commands"
                "fabric-api"
                "fastback"
                # "fastghast"
                "ferrite-core"
                # "floodgate"
                # "journeymap"
                # "krypton"
                "lithium"
                "scalablelux"
                "servercore"
              ]
            )
            ++ lib.optionals (loader == "paper") [
              "essentialsx"
              "lagfixer"
              "axgraves"
              "seemore"
              # "chunker"

              # "chunkyborder"
            ]
            ++ [
              # "bluemap"
              "chunky"
              "squaremap"
              # "geyser"
              # "emotecraft"
              # "playit-companion"
              # "worldedit"
            ]
          ) (
            getFromPackages "mods"
          )
        );
    };
  };
}
