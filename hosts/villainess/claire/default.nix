let adminUser = "francois";
in {
  deploy = { inherit adminUser; };
  importer = {
    services = {
      hosted = {
        forgejo.enable = true;
        postgres.enable = true;
        home-assistant.enable = true;
        nextcloud.enable = true;
        vaultwarden.enable = true;
      };
      acme.enable = true;
    };
  };
  modules = [
    ({ inputs, pkgs, config, flakeRoot, ... }: {
      imports = [ 
        (flakeRoot + "/modules/disko/ext4.nix") 
         inputs.clan-core.clanModules.nginx 
         inputs.clan-core.clanModules.postgresql 
      ];
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = true;
      };
      disko.devices.disk.main.device =
        "/dev/disk/by-id/ata-SAMSUNG_SSD_PM871b_M.2_2280_128GB_S3U2NE0M643392";
      networking.domains = [ "home.stanley-dev.net" ];

      clan.nginx.acme.email = "contact@stanley-dev.net";
      services.nextcloud = {

        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            contacts calendar tasks mail cospend;
        };
      };

      services.home-assistant = {
        extraComponents = [
          "wled"
          "vlc"
          "zha" # zigbee
          "esphome"
          "radio_browser"
          "homekit"
          "homekit_controller"
          "nextcloud"
        ];
        customComponents = with pkgs.home-assistant-custom-components; [
          tuya_local

          spook
        ];
        config = {
          media_player = [{
            platform = "vlc";
            arguments = "'--alsa-audio-device=hw:1,0' ";
          }];

          tts.platform = "google_translate";
        };
      };

    })
  ];
}
