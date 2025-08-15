{config, ...}: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        sidePanelWidth = 0.20;
        language = "en";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "${config.programs.git.extraConfig.core.pagerWit}";
        };
      };
    };
  };
}
