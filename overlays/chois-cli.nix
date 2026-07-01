{ chois-cli-src, ... }: final: prev: {
  chois = final.buildGoModule {
    pname = "chois";
    version = "4.0.0";
    src = chois-cli-src;
    vendorHash = "sha256-K/ooIxq+TjvDSygBpZR/Z2SNhnRnU9Cr7R0u7VCmRSQ=";
    subPackages = [ "cmd/chois" ];
  };
}
