let
  # sed -i "/string=\"$string\"/s/^\s*#\s*/ /"
  # sed  "/\"$dns\"/s/^\(\s*\)\/\/\s*/\1 /"
  # sed  "/github.com\/go-acme\/lego\/v4\/providers\/dns\/$dns\"/s/^\(\s*\)\/\/\s*/\1 /"
  # sed  "/$dns\.NewDNSProvider/s/^\(\s*\)\/\/\s*/\1 /"
  dnsProviders = [
    "cloudflare"
    # "digitalocean"
    # "dnsimple"
    # "dnspod"
    # "dyn"
    # "gandi"
    # "google"
    # "linode"
    # "namecheap"
    # "ovh"
    # "rfc2136"
    # "route53"
    # "sakuracloud"
    # "transip"
  ];
  nixpkgs = import <nixpkgs> {};
in
  nixpkgs.callPackage ./package.nix {inherit dnsProviders;}
