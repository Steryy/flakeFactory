{
  lib,
  python3,
  fetchFromGitHub,
  stdenv,
  fish,
  makeWrapper,
  bash,
  imagemagick,
  wl-clipboard,
  fuzzel,
  socat,
  foot,
  jq,
  grim,
  wayfreeze,
  wl-screenrec,
  git,
  coreutils,
  findutils,
  gnugrep,
  xdg-user-dirs,
}: let
  mypython = python3.withPackages (ps:
    with ps; [
      materialyoucolor
      pillow
    ]);
in
  stdenv.mkDerivation rec {
    pname = "caelestia-cli";
    version = "unstable-2025-07-12";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "caelestia-dots";
      repo = "cli";
      rev = "4b666a797e5f0365aef75bbc28ee9bb83378450e";
      hash = "sha256-60GdtCjNtwRCHnIlRak3Hl6hJQPtINoS7g5bb5e60P4=";
    };

    nativeBuildInputs = [
      makeWrapper
    ];

    patchPhase = ''
      # Fix hardcoded paths to use XDG directories
      # For Fish files - use $HOME which Fish understands
      find . -name "*.fish" -type f | while read -r file; do
        # Replace specific patterns found in the scripts
        sed -i 's|$src/../data/schemes|$HOME/.local/share/caelestia/schemes|g' "$file"
        sed -i 's|(dirname (status filename))/data|$HOME/.local/share/caelestia|g' "$file"
        sed -i 's|$src/data|$HOME/.local/share/caelestia|g' "$file"
      done

      # For Python files
      find . -name "*.py" -type f | while read -r file; do
        sed -i 's|os.path.join(os.path.dirname(__file__), "..", "data")|os.path.expanduser("~/.local/share/caelestia")|g' "$file"
        sed -i 's|Path(__file__).parent.parent / "data"|Path.home() / ".local" / "share" / "caelestia"|g' "$file"
      done
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/caelestia-scripts

      # Copy all the scripts to share directory
      cp -r * $out/share/caelestia-scripts/

      # Fix Python shebangs for NixOS with the wrapped Python
      find $out/share/caelestia-scripts -name "*.py" -type f -exec sed -i '1s|^#!/bin/python3|#!${mypython}/bin/python3|' {} \;
      find $out/share/caelestia-scripts -name "*.py" -type f -exec sed -i '1s|^#!/bin/python|#!${mypython}/bin/python|' {} \;
      find $out/share/caelestia-scripts -name "*.py" -type f -exec sed -i '1s|^#!/usr/bin/env python3|#!${mypython}/bin/python3|' {} \;
      find $out/share/caelestia-scripts -name "*.py" -type f -exec sed -i '1s|^#!/usr/bin/env python|#!${mypython}/bin/python|' {} \;

      # Make Python scripts executable
      find $out/share/caelestia-scripts -name "*.py" -type f -exec chmod +x {} \;

      # Create a setup script that ensures data directories exist
      cat > $out/bin/caelestia-setup <<EOF
      #!/bin/sh
      DATA_HOME="\$HOME/.local/share/caelestia"
      STATE_HOME="\$HOME/.local/state/caelestia"
      CACHE_HOME="\$HOME/.cache/caelestia"

      mkdir -p "\$DATA_HOME/schemes/dynamic"
      mkdir -p "\$STATE_HOME/wallpaper"
      mkdir -p "\$CACHE_HOME/schemes"

      # Copy data files if they don't exist
      if [ ! -d "\$DATA_HOME/schemes" ] && [ -d "$out/share/caelestia-scripts/data/schemes" ]; then
        cp -r "$out/share/caelestia-scripts/data/schemes" "\$DATA_HOME/"
      fi
      if [ ! -f "\$DATA_HOME/config.json" ] && [ -f "$out/share/caelestia-scripts/data/config.json" ]; then
        cp "$out/share/caelestia-scripts/data/config.json" "\$DATA_HOME/"
      fi
      if [ ! -f "\$DATA_HOME/emojis.txt" ] && [ -f "$out/share/caelestia-scripts/data/emojis.txt" ]; then
        cp "$out/share/caelestia-scripts/data/emojis.txt" "\$DATA_HOME/"
      fi
      EOF
      chmod +x $out/bin/caelestia-setup

      # Create wrapper for main script with all required tools in PATH
      makeWrapper ${bash}/bin/bash $out/bin/caelestia \
        --add-flags "$out/share/caelestia-scripts/run.sh" \
        --run "$out/bin/caelestia-setup" \
        --prefix PATH : ${lib.makeBinPath [
        imagemagick
        wl-clipboard
        fuzzel
        socat
        foot
        jq
        mypython
        grim
        wayfreeze
        wl-screenrec
        git
        coreutils
        findutils
        gnugrep
        xdg-user-dirs
      ]}
    '';
    buildInputs = [
      mypython
      fish
    ];

    meta = {
      description = "The main control script for the Caelestia dotfiles";
      homepage = "https://github.com/caelestia-dots/cli";
      license = lib.licenses.gpl3Only;
      # maintainers = with lib.maintainers; [ ];
      mainProgram = "caelestia-cli";
    };
  }
