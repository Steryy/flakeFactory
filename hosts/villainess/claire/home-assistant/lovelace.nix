{pkgs, ...}: {

  services.home-assistant = {
    lovelaceConfig = {
      strategy = {
        type = "custom:mushroom-strategy";
      };
      views = [];
    };
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      card-mod
      mini-graph-card
      (pkgs.callPackage ./packages/moshroom-strategy.nix {})
      mushroom
    ];

  };
}
