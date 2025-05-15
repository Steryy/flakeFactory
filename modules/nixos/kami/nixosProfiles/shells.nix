{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  programs.direnv.enable = true;
  # programs.bash = {
  #   enable = true;
  # };

  environment.pathsToLink = ["/share/zsh"];
}
