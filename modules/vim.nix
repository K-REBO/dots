{ config, pkgs, ... }:

{
  programs.vim = {
    enable = true;

    settings = {
      # 行番号表示
      number = true;

      # タブ設定
      tabstop = 4;
      shiftwidth = 4;
    };

    extraConfig = ''
      " シンタックスハイライト有効
      syntax on

      " 行の折り返しなし
      set nowrap

      " ESC ESC でハイライト解除
      nnoremap <ESC><ESC> :nohl<CR>
    '';
  };
}
