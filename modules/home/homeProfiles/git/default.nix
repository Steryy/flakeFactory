{
  pkgs,
  cell,
  config,
  ...
}: let
  gitIdentity = pkgs.writeShellScriptBin "git-identity" (builtins.readFile ./__git-identities.sh);

  inherit (cell.functions.keys) getGpgIdentity;
  identities =
    if config ? "keys" && config.keys != {}
    then
      getGpgIdentity
      config.keys
    else {};
  cfg = config.programs.git;
in {
  home.packages = with pkgs; [
    gitIdentity
    fzf
    # cfg.delta.package
  ];
  programs.git = {
    enable = true;
    # hooks = {
    #   pre-commit = ./pre-commit-script;
    # };

    aliases = {
      identity = "! git-identity";
      id = "! git-identity";
    };
    extraConfig = let
      deltaPackage = cfg.delta.package;
      deltaCommand = "${deltaPackage}/bin/delta --paging=never";
    in {
      init.defaultbranch = "main";
      user = identities;

      core.pagerWit = "${deltaCommand} ";

      url = {
        # core = {G
        #   sshCommand = "ssh -i ~/.ssh/github_main.pub -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        # };
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
        "git@codeberg.org:" = {
          insteadOf = "https://codeberg.org/";
        };
      };
    };

    delta = {
      enable = true;
      options = {
        paging = "never";
        dark = true;
        decorations = {
          # commit-decoration-style = "bold yellow box ul";
          # file-decoration-style = "none";
          # file-style = "bold yellow ul";
          syntax-theme = "base16-stylix";
          blame-palette = ''"#1e1e2e #181825 #11111b #313244 #45475a"'';
          commit-decoration-style = ''"#6c7086" bold box ul'';
          dark = true;
          file-decoration-style = ''"#6c7086"'';
          file-style = ''"#cdd6f4"'';
          hunk-header-decoration-style = ''"#6c7086" box ul'';
          hunk-header-file-style = ''bold'';
          hunk-header-line-number-style = ''bold "#a6adc8"'';
          hunk-header-style = ''file line-number syntax'';
          line-numbers-left-style = ''"#6c7086"'';
          line-numbers-minus-style = ''bold "#f38ba8"'';
          line-numbers-plus-style = ''bold "#a6e3a1"'';
          line-numbers-right-style = ''"#6c7086"'';
          line-numbers-zero-style = ''"#6c7086"'';
          minus-emph-style = ''bold syntax "#53394c"'';
          minus-style = ''syntax "#34293a"'';
          plus-emph-style = ''bold syntax "#404f4a"'';
          plus-style = ''syntax "#2c3239"'';
          map-styles = builtins.concatStringsSep "," (
            map (x: "bold ${x.col} => syntax ${x.hex}") [
              {
                col = "purple";
                hex = "#494060";
              }
              {
                col = "blue";
                hex = "#384361";
              }
              {
                col = "cyan";
                hex = "#384d5d";
              }
              {
                col = "yellow";
                hex = "#544f4e";
              }
            ]
          );
        };
        line-numbers = true;
        hyperlinks = true;
        hyperlinks-file-link-format = "lazygit-edit://{path}:{line}";
        features = "decorations";
        whitespace-error-style = "22 reverse";
      };
    };
  };
}
