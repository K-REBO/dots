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

  # Alacritty (TERM=alacritty) は実際は withGraphics=true ビルドで
  # Sixel 出力に対応しているが、上流のterm allowlistに含まれておらず
  # "Terminal does not support graphics" になるため許可リストに追加する
  postPatch = ''
    substituteInPlace kitty-graphics.el \
      --replace-fail '"xterm\\|vt[0-9]\\|foot\\|contour"' '"xterm\\|vt[0-9]\\|foot\\|contour\\|alacritty"'
  '';

  meta = {
    description = "Display images, video, and scaled text directly in terminal Emacs using the Kitty graphics protocol, tmux or Sixel";
    homepage = "https://github.com/cashmeredev/kitty-graphics.el";
    license = lib.licenses.gpl2Plus;
  };
}
