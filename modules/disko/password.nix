{pkgs, ...}: {
  clan.core.vars.generators.diskpassword = {
    prompts.diskpassword.type = "hidden";
    prompts.diskpassword.persist = true;
    prompts.diskpassword.description = "You can autogenerate a password, if you leave this prompt blank.";
    files.diskpassword = {
      neededFor = "partitioning";
    };

    runtimeInputs = with pkgs; [
      coreutils
      xkcdpass
      mkpasswd
    ];
    script = ''
      prompt_value=$(cat "$prompts"/diskpassword)
      if [[ -n "''${prompt_value-}" ]]; then
        echo "$prompt_value" | tr -d "\n" > "$out"/diskpassword
      else
        xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > "$out"/diskpassword
      fi
    '';
  };
}
