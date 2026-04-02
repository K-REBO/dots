{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # ============================================================
    # Aliases
    # ============================================================
    shellAliases = {
      # Basic utilities
      less = "less -Q -R";
      wcopy = "wl-copy";
      wpaste="wl-paste --type 'text/plain;charset=utf-8'";
      beep="play -n synth 0.3 sine 1000 > /dev/null 2>&1";

      # eza (ls replacement)
      ls = "eza";
      l = "ls";
      l1 = "eza -1";
      la = "eza -a";
      ll = "eza -l -h -@ -m --time-style=iso";
      lla = "eza -lh@ma --time-style=iso";
      lal = "eza -lh@ma --time-style=iso";

      # Other tools
      #z = "zoxide";
      dust = "dust -r";
      oc = "obsidian-cli";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......." = "cd ../../../../..";

      # translate-shell via docker
      trans = "docker run -it soimort/translate-shell -shell";

      # wget without history file
      wget = "wget --no-hsts";

      # claude-code
      claude = "bunx @anthropic-ai/claude-code";

      # Emacs: ターミナルから起動した場合は -nw（TUI）モード
      emacs = "emacs -nw";
    };

    # ============================================================
    # History configuration
    # ============================================================
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    # ============================================================
    # Completion system
    # ============================================================
    enableCompletion = true;

    # ============================================================
    # Shell options and initialization
    # ============================================================
    initContent = ''
      # ============================================================
      # Environment variables
      # ============================================================
      export GO_HOME="$HOME/.go"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.deno/bin:$PATH"
      export PATH="$HOME/.moon/bin:$PATH"
      export PATH="$GO_HOME/bin:$PATH"

      # LD_LIBRARY_PATH
      export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"

      # Set LD_LIBRARY_PATH for Playwright
      if [[ ":$LD_LIBRARY_PATH:" != *":/home/bido/.local/lib/playwright:"* ]]; then
          export LD_LIBRARY_PATH="/home/bido/.local/lib/playwright:''${LD_LIBRARY_PATH}"
      fi

      # .envファイルがあればsource（秘密情報用）
      if [ -f ~/.env ]; then
        source ~/.env
      fi

      # ============================================================
      # Completion system
      # ============================================================
      # Add custom completion directory to fpath
      fpath+=~/.zfunc

      # Enable zsh completion system
      autoload -Uz compinit
      compinit

      # Fish-like completion behavior
      # Menu completion: TAB cycles through candidates immediately
      setopt MENU_COMPLETE        # Insert first match immediately, TAB to cycle
      setopt AUTO_LIST            # List choices on ambiguous completion
      unsetopt AUTO_MENU          # Disable auto menu (conflicts with MENU_COMPLETE)
      unsetopt LIST_AMBIGUOUS     # Show menu immediately

      # Case-insensitive completion (fish-like)
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # Partial completion support (e.g., cd /u/lo/b -> /usr/local/bin)
      zstyle ':completion:*' list-suffixes
      zstyle ':completion:*' expand prefix suffix

      # Color completion menu (similar to fish)
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Tab and Shift-Tab for cycling through completions
      bindkey '^I' menu-complete              # TAB
      bindkey '^[[Z' reverse-menu-complete    # Shift-TAB

      # mcfly・Claude CodeなどのTUIアプリがkitty keyboard protocolを有効化したまま
      # 終了することがある（Ctrl+C等で異常終了した場合）。その状態ではCtrl+J等が
      # 生のCSI uシーケンスとして表示されるため、各プロンプト表示前にリセットする。
      _reset_kitty_keyboard() {
        printf '\e[<u'  # スタックからpop（有効化前の状態に戻す）
      }
      add-zsh-hook precmd _reset_kitty_keyboard

      # ============================================================
      # mise (runtime manager) - Home Managerにmiseモジュールがないため手動
      # ============================================================
      eval "$(mise activate zsh)"
      eval "$(mise activate zsh --shims)"

      # ============================================================
      # Custom functions
      # ============================================================
      greet() {
          gh grass --animate
      }

      fish_greeting() {
          fortune | cowsay -f ghostbusters
          figlet "Ghost Busters!"
          echo "🐟"
      }

      # ============================================================
      # External scripts
      # ============================================================
      if [ -f ~/.config/dots/installedPackages/autoAdd.sh ]; then
          bash ~/.config/dots/installedPackages/autoAdd.sh
      fi

      # ============================================================
      # Display greeting on shell start
      # ============================================================
      fortune | cowsay -f ghostbusters

      # ============================================================
      # Zsh plugins - autosuggestions color configuration
      # ============================================================
      # zsh-autosuggestions color (fish_color_autosuggestion: 969896)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#969896'
    '';

    # ============================================================
    # Zsh plugins
    # ============================================================
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
    ];

    # ============================================================
    # Syntax highlighting
    # ============================================================
    syntaxHighlighting = {
      enable = true;
      styles = {
        # fish_color_command: c397d8 (purple/magenta)
        command = "fg=#c397d8";
        alias = "fg=#c397d8";
        builtin = "fg=#c397d8";
        function = "fg=#c397d8";
        precommand = "fg=#c397d8";

        # fish_color_param: 7aa6da (blue)
        arg0 = "fg=#c397d8";
        default = "fg=#7aa6da";
        unknown-token = "fg=#d54e53";

        # fish_color_quote: b9ca4a (green)
        single-quoted-argument = "fg=#b9ca4a";
        double-quoted-argument = "fg=#b9ca4a";
        dollar-quoted-argument = "fg=#b9ca4a";

        # fish_color_redirection: 70c0b1 (cyan)
        redirection = "fg=#70c0b1";

        # fish_color_operator: 00a6b2 (cyan)
        commandseparator = "fg=#00a6b2";

        # fish_color_comment: e7c547 (yellow)
        comment = "fg=#e7c547";

        # fish_color_valid_path: underline
        path = "fg=#7aa6da,underline";
        path_prefix = "fg=#7aa6da,underline";
        path_approx = "fg=#7aa6da,underline";

        # fish_color_escape: 00a6b2 (cyan)
        back-quoted-argument = "fg=#00a6b2";
        back-quoted-argument-delimiter = "fg=#00a6b2";
        single-hyphen-option = "fg=#7aa6da";
        double-hyphen-option = "fg=#7aa6da";

        # Globbing
        globbing = "fg=#7aa6da";
        history-expansion = "fg=#00a6b2";

        # Reserved words (if, then, else, etc.)
        reserved-word = "fg=#c397d8";

        # Assign
        assign = "fg=#7aa6da";
      };
    };
  };

  # ============================================================
  # Zsh completions (custom CLI tools)
  # ============================================================
  home.file.".zfunc/_twitter" = {
    text = ''
      #compdef twitter

      _twitter() {
        local -a commands
        commands=(
          'article:Fetch a Twitter Article'
          'bookmark:Bookmark a tweet'
          'bookmarks:Fetch bookmarked tweets, or manage bookmark folders'
          'delete:Delete a tweet'
          'favorite:Bookmark (favorite) a tweet'
          'favorites:Fetch bookmarked (favorite) tweets'
          'feed:Fetch home timeline with optional filtering'
          'follow:Follow a user'
          'followers:List followers of a user'
          'following:List accounts a user is following'
          'like:Like a tweet'
          'likes:Show tweets liked by a user'
          'list:Fetch tweets from a Twitter List'
          'post:Post a new tweet'
          'quote:Quote-tweet a tweet'
          'reply:Reply to a tweet'
          'retweet:Retweet a tweet'
          'search:Search tweets by QUERY string with optional advanced filters'
          'show:View tweet from last feed/search results'
          'status:Check whether the current Twitter/X session is authenticated'
          'tweet:View a tweet and its replies'
          'unbookmark:Remove a tweet from bookmarks'
          'unfavorite:Remove a tweet from bookmarks (unfavorite)'
          'unfollow:Unfollow a user'
          'unlike:Unlike a tweet'
          'unretweet:Undo a retweet'
          'user:View a user profile'
          'user-posts:List a user tweets'
          'whoami:Show the currently authenticated user profile'
        )

        local curcontext="$curcontext" state line
        typeset -A opt_args

        _arguments -C \
          '(-v --verbose)'{-v,--verbose}'[Enable debug logging]' \
          '(-c --compact)'{-c,--compact}'[Compact output (minimal fields, LLM-friendly)]' \
          '--version[Show the version and exit]' \
          '--help[Show this message and exit]' \
          '1: :->command' \
          '*:: :->args' && return 0

        case $state in
          command)
            _describe 'twitter command' commands
            ;;
          args)
            case $line[1] in
              article)    _twitter_article ;;
              bookmark)   _twitter_bookmark ;;
              bookmarks)  _twitter_bookmarks ;;
              delete)     _twitter_delete ;;
              favorite)   _twitter_favorite ;;
              favorites)  _twitter_favorites ;;
              feed)       _twitter_feed ;;
              follow)     _twitter_follow ;;
              followers)  _twitter_followers ;;
              following)  _twitter_following ;;
              like)       _twitter_like ;;
              likes)      _twitter_likes ;;
              list)       _twitter_list ;;
              post)       _twitter_post ;;
              quote)      _twitter_quote ;;
              reply)      _twitter_reply ;;
              retweet)    _twitter_retweet ;;
              search)     _twitter_search ;;
              show)       _twitter_show ;;
              status)     _twitter_status ;;
              tweet)      _twitter_tweet ;;
              unbookmark) _twitter_unbookmark ;;
              unfavorite) _twitter_unfavorite ;;
              unfollow)   _twitter_unfollow ;;
              unlike)     _twitter_unlike ;;
              unretweet)  _twitter_unretweet ;;
              user)       _twitter_user ;;
              user-posts) _twitter_user_posts ;;
              whoami)     _twitter_whoami ;;
            esac
            ;;
        esac
      }

      _twitter_article() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-m --markdown)'{-m,--markdown}'[Output article as Markdown]' \
          '(-o --output)'{-o,--output}'[Save article Markdown to file]:file:_files' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_bookmark() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_bookmarks() {
        local -a subcmds
        subcmds=('folders:List bookmark folders, or fetch tweets from a folder')

        local curcontext="$curcontext" state line
        typeset -A opt_args

        _arguments -C \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1: :->subcmd' \
          '*:: :->args' && return 0

        case $state in
          subcmd)
            _describe 'bookmarks subcommand' subcmds
            ;;
          args)
            case $line[1] in
              folders) _twitter_bookmarks_folders ;;
            esac
            ;;
        esac
      }

      _twitter_bookmarks_folders() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max tweets to fetch from folder]:number: ' \
          '--since[Only show tweets after this date (YYYY-MM-DD)]:date: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1:FOLDER_ID: '
      }

      _twitter_delete() {
        _arguments \
          '--yes[Confirm the action without prompting]' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_favorite() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_favorites() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]'
      }

      _twitter_feed() {
        _arguments \
          '(-t --type)'{-t,--type}'[Feed type (for-you\: algorithmic, following\: chronological)]:type:(for-you following)' \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-i --input)'{-i,--input}'[Load tweets from JSON file]:file:_files' \
          '(-o --output)'{-o,--output}'[Save filtered tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]'
      }

      _twitter_follow() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_followers() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max users to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_following() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max users to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_like() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_likes() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_list() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1:LIST_ID: '
      }

      _twitter_post() {
        _arguments \
          '(-r --reply-to)'{-r,--reply-to}'[Reply to this tweet ID]:tweet_id: ' \
          '*'{-i,--image}'[Attach image (up to 4, repeatable)]:image:_files -g "*.{jpg,jpeg,png,gif,webp}"' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TEXT: '
      }

      _twitter_quote() {
        _arguments \
          '*'{-i,--image}'[Attach image (up to 4, repeatable)]:image:_files -g "*.{jpg,jpeg,png,gif,webp}"' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: ' \
          '2:TEXT: '
      }

      _twitter_reply() {
        _arguments \
          '*'{-i,--image}'[Attach image (up to 4, repeatable)]:image:_files -g "*.{jpg,jpeg,png,gif,webp}"' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: ' \
          '2:TEXT: '
      }

      _twitter_retweet() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_search() {
        _arguments \
          '(-t --type)'{-t,--type}'[Search tab]:type:(top latest photos videos)' \
          '--from[Only tweets from this user]:screen_name: ' \
          '--to[Only tweets directed at this user]:screen_name: ' \
          '--lang[Filter by language ISO code (e.g. en, fr, ja)]:lang: ' \
          '--since[Tweets since date (YYYY-MM-DD)]:date: ' \
          '--until[Tweets until date (YYYY-MM-DD)]:date: ' \
          '*--has[Require content type (repeatable)]:content_type:(links images videos media)' \
          '*--exclude[Exclude content type (repeatable)]:content_type:(retweets replies links)' \
          '--min-likes[Minimum number of likes]:number: ' \
          '--min-retweets[Minimum number of retweets]:number: ' \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--filter[Enable score-based filtering]' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1:QUERY: '
      }

      _twitter_show() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max replies to fetch]:number: ' \
          '--full-text[Show full reply text in table output]' \
          '(-o --output)'{-o,--output}'[Save tweet detail as JSON to file]:file:_files' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:INDEX: '
      }

      _twitter_status() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]'
      }

      _twitter_tweet() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max replies to fetch]:number: ' \
          '--full-text[Show full reply text in table output]' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_unbookmark() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_unfavorite() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_unfollow() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_unlike() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_unretweet() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:TWEET_ID: '
      }

      _twitter_user() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_user_posts() {
        _arguments \
          '(-n --max)'{-n,--max}'[Max number of tweets to fetch]:number: ' \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '(-o --output)'{-o,--output}'[Save tweets to JSON file]:file:_files' \
          '--full-text[Show full tweet text in table output]' \
          '--help[Show this message and exit]' \
          '1:SCREEN_NAME: '
      }

      _twitter_whoami() {
        _arguments \
          '--json[Output as JSON]' \
          '--yaml[Output as YAML]' \
          '--help[Show this message and exit]'
      }

      _twitter "$@"
    '';
  };

  # ============================================================
  # Additional packages needed for zsh setup
  # ============================================================
  home.packages = with pkgs; [
    mise      # Runtime manager (Home Managerモジュールがないため)
    fortune   # For greeting
    cowsay    # For greeting
    figlet    # For greeting
    sox       # for beep
  ];
  # zoxide, mcfly, gh は programs.* で管理されるため削除
}
