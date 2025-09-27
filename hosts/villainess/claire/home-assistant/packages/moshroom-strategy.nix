{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "mushroom-strategy";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "DigiLive";
    repo = "mushroom-strategy";
    tag = "v${version}";
    hash = 
"sha256-8Z2ln5uvZ9rGclXHcWnAI6WSudn62Fe+qcZwkUORwO4=";
# lib.fakeHash ;
      # "sha256-flZfOVY0/xZOL1ZktRGQhRyGAZronLAjpM0zFpc+X1U=";
  };

  npmDepsHash = 
    "sha256-AIUOEri5HT5qPj+xZ5tTEl2uqo7PVQhdqcD//pm9PW4=";
# lib.fakeHash ;
    # "sha256-xzhyYYZLl8pyfK3+MRn35Ffdw/c78v8PjwLlAuQO92g=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v dist/mushroom-strategy.js $out/

    runHook postInstall
  '';

  passthru.entrypoint = "mushroom-strategy.js";

  # meta = with lib; {
  #   changelog = "https://github.com/kalkih/mini-graph-card/releases/tag/v${version}";
  #   description = "Minimalistic graph card for Home Assistant Lovelace UI";
  #   homepage = "https://github.com/kalkih/mini-graph-card";
  #   maintainers = with maintainers; [ hexa ];
  #   license = licenses.mit;
  # };
}
