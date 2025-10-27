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

    settings = let
    in {
      aliases = {
        identity = "! git-identity";
        id = "! git-identity";
      };
      init.defaultbranch = "main";
      user = identities;

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
  };
}
