# https://github.com/public-clis/twitter-cli
final: prev: let
  pyPkgs = prev.python3.pkgs;
  xclienttransaction = pyPkgs.buildPythonPackage rec {
    pname = "xclienttransaction";
    version = "1.0.2";
    format = "wheel";
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/x/xclienttransaction/xclienttransaction-${version}-py3-none-any.whl";
      sha256 = "sha256-ZiUVVPAkcs0Ps6M7xkaM/rdAlJdU3cB9vkFk5DmshhM=";
    };
    dependencies = with pyPkgs; [ beautifulsoup4 ];
    pythonRuntimeDepsCheckHook = false;
    doCheck = false;
  };
in {
  twitter-cli = pyPkgs.buildPythonApplication rec {
    pname = "twitter-cli";
    version = "0.8.5";
    format = "wheel";
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/t/twitter_cli/twitter_cli-${version}-py3-none-any.whl";
      sha256 = "sha256-sudyBOrnFZ4Q4Znjv1KWppFGlFeSnN+QoHDMUXLzkxc=";
    };
    dependencies = with pyPkgs; [
      beautifulsoup4
      browser-cookie3
      click
      curl-cffi
      pyyaml
      rich
      xclienttransaction
    ];
    doCheck = false;
  };
}
