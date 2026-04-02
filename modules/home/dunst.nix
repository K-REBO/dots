{ pkgs, ... }:

{
  services.dunst = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      size = "32x32";
    };

    settings = {
      global = {
        # 位置・サイズ
        origin = "top-right";
        offset = "16x16";
        width = "(200, 400)";
        notification_limit = 5;

        # 見た目
        corner_radius = 8;
        frame_width = 2;
        frame_color = "#ff6600";
        separator_height = 1;
        separator_color = "frame";
        padding = 10;
        horizontal_padding = 14;
        text_icon_padding = 10;

        # フォント
        font = "Noto Sans 11";

        # テキスト
        format = "<b>%s</b>\\n%b";
        markup = "full";
        ellipsize = "end";
        word_wrap = true;
        max_icon_size = 48;

        # 透過
        transparency = 10;

        # タイムアウト（デフォルト）
        idle_threshold = 120;

        # アニメーション
        show_age_threshold = -1;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        # マウス操作
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#1a1a1a";
        foreground = "#aaaaaa";
        frame_color = "#595959";
        timeout = 4;
      };

      urgency_normal = {
        background = "#1e1e1e";
        foreground = "#e0e0e0";
        frame_color = "#ff6600";
        timeout = 6;
      };

      urgency_critical = {
        background = "#2a1010";
        foreground = "#ff6666";
        frame_color = "#ff3333";
        timeout = 0;  # 手動で閉じるまで表示
      };
    };
  };

  # hyprland.nixで個別パッケージとして追加しているdunstを重複させないため、
  # libnotify（notify-send コマンド）だけを残す
  home.packages = [ pkgs.libnotify ];
}
