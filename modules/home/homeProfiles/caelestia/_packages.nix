{
  pkgs,
  lib,
  ...
}: let
  mypython = pkgs.python3.withPackages (ps:
    with ps; [
      materialyoucolor
      pillow
    ]);

  caelestia-shell = pkgs.clangStdenv.mkDerivation rec {
    pname = "caelestia-shell";
    version = "main";

    src = pkgs.fetchFromGitHub {
      owner = "caelestia-dots";
      repo = "shell";
      "rev" = "6455f6c719a6e93502433ee4f4f1cda8036c348d";
      "hash" = "sha256-+uXI5KNBv/ncgdrxZrOHgTK9pA2il9L1C1i9WiDJpeY=";
    };

    nativeBuildInputs = with pkgs; [
      gcc
      makeWrapper
      pkg-config
      pipewire.dev
      libspatialaudio
      aubio
    ];

    buildPhase = ''
      mkdir -p $out/bin
      g++ -std=c++17 -O2 assets/beat_detector.cpp -o $out/bin/beat_detector \
        $(pkg-config --cflags --libs libpipewire-0.3 libspa-0.2 aubio)
    '';

    fixupPhase = ''
      for prog in $(find $out -type f -name "*.qml" ); do
          if grep -qF '/usr/lib/caelestia/beat_detector' $prog ; then
            substituteInPlace $prog --replace '/usr/lib/caelestia/beat_detector' "$out/bin/beat_detector"
          fi
      done
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/caelestia
      cp -r * $out/share/caelestia/
    '';
  };
  # Caelestia scripts derivation with Python shebang fixes
  caelestia-scripts = pkgs.stdenv.mkDerivation rec {
    pname = "caelestia-scripts";
    version = "unstable-2024-01-07";

    src = pkgs.fetchFromGitHub {
      owner = "caelestia-dots";
      repo = "cli";
      "rev" = "49db0a8258e0ae26d1787d5fb3a930f4534ea1a5";
      "hash" = "sha256-+E89sdCWgqQuJ7lNWg1iKJqNAM9UEgBQqYa/HcvBoTY=";
      # rev = "2664749c75417b947efdd9ab1b136aaa0ade42b2";
      # hash = "sha256-kHbGBqXZS8M38CtMng2b/88+l1Od9FfRijycHTfDGZ4=";
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];

    buildInputs = with pkgs; [
      fish
      mypython
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
      makeWrapper ${pkgs.bash}/bin/bash $out/bin/caelestia \
        --add-flags "$out/share/caelestia-scripts/run.sh" \
        --run "$out/bin/caelestia-setup" \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
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
      ])}
    '';

    meta = with lib; {
      description = "Caelestia dotfiles scripts";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  # Wrap quickshell with Qt dependencies and required tools in PATH

  caelestia-quickshell = pkgs. writeScriptBin "caelestia-quickshell" ''
    #!${pkgs.fish}/bin/fish

    # Override for caelestia shell commands to work with quickshell
    set -l original_caelestia ${caelestia-scripts}/bin/caelestia

    if test "$argv[1]" = "shell" -a -n "$argv[2]"
        set -l cmd $argv[2]
        set -l args $argv[3..]

        switch $cmd
            case "show" "toggle"
                if test -n "$args[1]"
                    exec qs -c caelestia ipc call drawers $cmd $args[1]
                else
                    echo "Usage: caelestia shell $cmd <drawer>"
                    exit 1
                end
            case "media"
                if test -n "$args[1]"
                    set -l action $args[1]
                    switch $action
                        case "play-pause"
                            exec qs -c caelestia ipc call mpris playPause
                        case '*'
                            exec qs -c caelestia ipc call mpris $action
                    end
                else
                    echo "Usage: caelestia shell media <action>"
                    exit 1
                end
            case '*'
                # For other shell commands, try the original
                exec $original_caelestia $argv
        end
    else
        # For non-shell commands, use the original
        exec $original_caelestia $argv
    end
  '';
in {
  inherit
    caelestia-shell
    caelestia-scripts
    caelestia-quickshell
    ;
}
