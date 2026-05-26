{ gh-grass-src, ... }: final: prev: {
  gh-grass = final.buildGoModule {
    pname = "gh-grass";
    version = "unstable-2025";
    src = gh-grass-src;
    vendorHash = "sha256-lvSdQ09zg8PfVSkKoZ49VwXRVmxI1J8IAONAHBXwmEg=";
  };
}
