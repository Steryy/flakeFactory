{ pkgs, lib, ... }: {
  programs.steam = {
    enable = lib.mkDefault true;
    extest.enable = lib.mkDefault true;
    protontricks.enable = true;

    package = pkgs.steam.override {
      extraEnv = {
        # MANGOHUD = true;
        OBS_VKCAPTURE = true;
        RADV_TEX_ANISO = 16;
      };
      extraLibraries = p: with p; [ atk ];
    };
    extraPackages =
      lib.mkDefault (with pkgs; [ pango libthai harfbuzz gamescope ]);
  };
  programs.gamescope.enable = true;
}
