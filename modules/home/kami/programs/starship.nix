{

  programs.bash.enable = true;
  programs.bash.shellAliases = {
    vi = "/home/myuri/projects/nvibu/result/bin/nvim";
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # command_timeout = 1300;
      # scan_timeout = 50;
      format = ''
        $all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status
        $username$hostname$directory'';
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };
}
