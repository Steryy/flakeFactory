{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.programs.quickshell;
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
      rev = "ee0f243ca36cad45718424433254304d53059df8";
      hash = "sha256-U45DVKm2Tso0NAbvv/eyZ8O46s/9hd20sc70EdYGS5c=";
      # sha256 = "196z5hgd8d3vpa4bkxizgxnc3fj4aakais3i6a30ankanya4df5j";
    };

    buildInputs = with pkgs; [
      # cfg.finalPackage
      gcc
      pipewire.dev
      libspatialaudio
      aubio
    ];

    nativeBuildInputs = with pkgs; [
      makeWrapper
      pkg-config
    ];
    buildPhase = ''
      mkdir -p $out/bin
      g++ -std=c++17 -O2 assets/beat_detector.cpp -o $out/bin/beat_detector \
        $(pkg-config --cflags --libs libpipewire-0.3 libspa-0.2 aubio)
    '';
    fixupPhase = ''

      for prog in $(find $out -type f -name "*.qml" ); do
          if grep -q 'app2unit' $prog ; then
            substituteInPlace $prog --replace 'app2unit' "${cfg.desktopRunCmd}"
          fi
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
      rev = "main";
      hash = "sha256-fGmOP1pVNZ9SXZIzEjUxWDXpUPBIFI/oRyINSUTarcM=";
      # sha256 = "196z5hgd8d3vpa4bkxizgxnc3fj4aakais3i6a30ankanya4df5j";
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
  quickshell-wrapped =
    pkgs.runCommand "quickshell-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      makeWrapper ${inputs.quickshell.packages.${pkgs.system}.default}/bin/qs $out/bin/qs \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix PATH : ${lib.makeBinPath [pkgs.fd pkgs.coreutils]}
    '';
in {
  options.programs.quickshell = {
    finalPackage = lib.mkOption {
      type = lib.types.package;
      default = quickshell-wrapped;
      description = "The wrapped quickshell package with Qt dependencies";
    };
    pythonPackage = lib.mkOption {
      type = lib.types.package;
      default = mypython;
    };
    desktopRunCmd = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.gtk3}/bin/gtk-launch";
    };
    celestialShell = lib.mkOption {
      type = lib.types.package;
      default = caelestia-shell;
    };

    caelestia-scripts = lib.mkOption {
      type = lib.types.package;
      default = caelestia-scripts;
      description = "The caelestia scripts package";
    };
  };
}
