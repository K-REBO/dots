{ chois-cli-src, ... }: final: prev: {
  chois = final.buildGoModule {
    pname = "chois";
    version = "2.0.0";
    src = chois-cli-src;
    vendorHash = "sha256-io86Y7RJm+j9OVAh+HhTpOMFw0btIpdNMXt3VecfPqw=";
    subPackages = [ "cmd/chois" ];
  };
}
