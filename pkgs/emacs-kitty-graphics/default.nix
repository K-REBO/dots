{ lib, fetchFromGitHub, melpaBuild }:

melpaBuild {
  pname = "kitty-graphics";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "cashmeredev";
    repo = "kitty-graphics.el";
    rev = "d9e1c25083d46968e11953cdc1d6294f2bfdfe58";
    hash = "sha256-ehQgeVLvHK075VIgrHnMSjkj4gRpcGCU9LJdXyE4pBY=";
  };

  recipe = builtins.toFile "kitty-graphics-recipe" ''
    (kitty-graphics :fetcher github :repo "cashmeredev/kitty-graphics.el")
  '';

  meta = {
    description = "Display images, video, and scaled text directly in terminal Emacs using the Kitty graphics protocol, tmux or Sixel";
    homepage = "https://github.com/cashmeredev/kitty-graphics.el";
    license = lib.licenses.gpl2Plus;
  };
}
