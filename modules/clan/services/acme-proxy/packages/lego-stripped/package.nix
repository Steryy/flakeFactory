{
  lib,
  applyPatches,
  buildGoModule,
  dnsProviders ? ["cloudflare"],
  useUpx ? true,
  upx,
}: let
  dnsP =
    if builtins.length dnsProviders == 0
    then throw "Specify what dns providers to enable"
    else dnsProviders;
in
  buildGoModule {
    pname = "lego-proxy";
    version = "1.0.0";

    # src = ./.;

    src = applyPatches {
      src = ./.;
      prePatch = lib.concatMapStringsSep "\n" (x: let
      in
        #bash
        ''
          dns="${x}";
          sed -i  "/\"$dns\"/s/^\(\s*\)\/\/\s*/\1 /" lego-stripped/provider.go
          sed  -i "/github.com\/go-acme\/lego\/v4\/providers\/dns\/$dns\"/s/^\(\s*\)\/\/\s*/\1 /" lego-stripped/provider.go
          sed -i "/$dns\.NewDNSProvider/s/^\(\s*\)\/\/\s*/\1 /" lego-stripped/provider.go

        '')
      dnsP;
    };

    vendorHash = "sha256-F7PmJ2JbMgXZ4MpQ3qtpZKm3pC3fq6fXRL7qAmYoQTE=";

    # Optional: set to false if you don't vendor dependencies
    vendor = false;
    subPackages = ["lego-stripped"];

    # Optional: you can also set `GO111MODULE = "on"` if needed
    # doCheck = false;
    ldflags = ["-s" "-w"];
    # nativeBuildInputs = with pkgs; [bash patch];
    # buildInputs = [upx];
    postInstall = ''
      ${
        lib.optionalString useUpx
        "${upx}/bin/upx --best --lzma  $out/bin/lego-stripped"
      }
    '';

    meta = with lib; {
      description = "Custom wrapper for LEGO ACME DNS providers";
      license = licenses.mit;
      # maintainers = with maintainers; [];
    };
  }
