{
  curl,
  jq,
  jo,
  lib,
  lldap,
  makeWrapper,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "lldap-bootstrap";
  inherit (lldap) src version meta;
  dontBuild = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp ./scripts/bootstrap.sh $out/bin/lldap-bootstrap

    wrapProgram $out/bin/lldap-bootstrap \
      --set LLDAP_SET_PASSWORD_PATH ${lldap}/bin/lldap_set_password \
      --prefix PATH : ${
      lib.makeBinPath [
        curl
        jq
        jo
      ]
    }
  '';
}
