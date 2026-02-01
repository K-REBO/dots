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

      "ctrlによるカーソル移動
       inoremap <C-p> <Up>
       cnoremap <C-p> <Up>
       noremap <C-n> j
       inoremap <C-n> <Down>
       cnoremap <C-n> <Down>
       noremap <C-f> l
       inoremap <C-f> <Right>
       cnoremap <C-f> <Right>
       noremap <C-b> h
       inoremap <C-b> <Left>
       cnoremap <C-b> <Left>
       " 行頭へ移動
       noremap <C-a> 0
       inoremap <C-a> <Home>
       cnoremap <C-a> <Home>
       " 行末へ移動
       noremap <C-e> $
       inoremap <C-e> <End>
       cnoremap <C-e> <End>

      " 前回のカーソル位置を復元
      autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    '';
  };
}
