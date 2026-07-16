{ lib, fetchFromGitHub, melpaBuild, dash, compat, magit-section, lsp-mode }:

melpaBuild {
  pname = "lean4-mode";
  version = "0-unstable-2025-06-01";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "lean4-mode";
    rev = "1388f9d1429e38a39ab913c6daae55f6ce799479";
    hash = "sha256-6XFcyqSTx1CwNWqQvIc25cuQMwh3YXnbgr5cDiOCxBk=";
  };

  packageRequires = [ dash compat magit-section lsp-mode ];

  recipe = builtins.toFile "lean4-mode-recipe" ''
    (lean4-mode :fetcher github :repo "leanprover-community/lean4-mode")
  '';

  meta = {
    description = "Major mode for the Lean 4 theorem prover and programming language";
    homepage = "https://github.com/leanprover-community/lean4-mode";
    license = lib.licenses.asl20;
  };
}
