{
  lib,
  clangStdenv,
  fetchFromGitHub,
  gcc,
  makeWrapper,
  pkg-config,
  pipewire,
  libspatialaudio,
  aubio,
}:
clangStdenv.mkDerivation rec {
  pname = "caelestia-shell";
  version = "unstable-2025-07-12";

  src = fetchFromGitHub {
    owner = "caelestia-dots";
    repo = "shell";
    rev = "178a63602530f44169ea740e4e1530a9a14212ea";
    hash = "sha256-FHPCSy/Fd9hIpFA2BxhTkbwBtY9vtvsEUYC3+ZX6zNQ=";
  };

  nativeBuildInputs = [
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

  meta = {
    description = "A very segsy desktop shell";
    homepage = "https://github.com/caelestia-dots/shell";
    license = lib.licenses.gpl3Only;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "caelestia-shell";
    platforms = lib.platforms.all;
  };
}
