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
  # PyPI 0.8.5 has a broken `search` command (SearchTimeline GET->POST change on
  # Twitter's side returns HTTP 404). The fix landed on `main` after the 0.8.5 tag
  # and hasn't been released to PyPI yet (0.8.6). Build from source until it is.
  # See: https://github.com/public-clis/twitter-cli/issues/39
  twitter-cli = pyPkgs.buildPythonApplication rec {
    pname = "twitter-cli";
    version = "0.8.6-unstable-2026-05-07";
    pyproject = true;
    src = final.fetchFromGitHub {
      owner = "public-clis";
      repo = "twitter-cli";
      rev = "7c634e0d396b1e7af9f63315b414925fe4f29ae7";
      hash = "sha256-i6tkJS98LTMM1q7LGleblHeEg5mr4yaPSRe30lt2iTs=";
    };
    build-system = with pyPkgs; [ hatchling ];
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
