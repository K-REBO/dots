{ chuoprint-cli-src, crane, ... }: final: prev: {
  cpr = (crane.mkLib final).buildPackage {
    src = chuoprint-cli-src;
    strictDeps = true;
    pname = "cpr";
  };
}
