#!/usr/bin/env python3
"""店名またはGoogle MapsのURLをブラウザ自動操作でGoogle Mapsのリストに保存するCLI。"""

import argparse
import re
import shutil
import sys
import urllib.parse
from pathlib import Path

from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright

PROFILE_DIR = Path.home() / ".local" / "share" / "google-map-bookmark" / "profile"
DEFAULT_LIST = "お気に入り"
NAV_TIMEOUT_MS = 30_000
UI_TIMEOUT_MS = 15_000


def is_url(query: str) -> bool:
    return bool(re.match(r"^https?://", query))


def build_search_url(query: str) -> str:
    return f"https://www.google.com/maps/search/{urllib.parse.quote(query)}"


def open_browser(headless: bool):
    PROFILE_DIR.mkdir(parents=True, exist_ok=True)
    playwright = sync_playwright().start()

    # Googleは自動化ブラウザのログインを「安全でない」として拒否するため、
    # Chromium同梱版ではなく実際のGoogle Chromeバイナリを使い、
    # 自動化フラグ(navigator.webdriver等)を隠す。
    chrome_path = shutil.which("google-chrome-stable") or shutil.which("google-chrome")

    launch_kwargs = dict(
        headless=headless,
        locale="ja-JP",
        viewport={"width": 1280, "height": 900},
        args=["--disable-blink-features=AutomationControlled"],
        ignore_default_args=["--enable-automation"],
    )
    if chrome_path:
        launch_kwargs["executable_path"] = chrome_path

    context = playwright.chromium.launch_persistent_context(
        str(PROFILE_DIR), **launch_kwargs
    )
    context.add_init_script(
        "Object.defineProperty(navigator, 'webdriver', { get: () => undefined });"
    )
    return playwright, context


def do_login() -> None:
    playwright, context = open_browser(headless=False)
    page = context.pages[0] if context.pages else context.new_page()
    page.goto("https://www.google.com/maps", timeout=NAV_TIMEOUT_MS)
    input(
        "ブラウザでGoogleにログインしてください。"
        "完了したらこのターミナルでEnterキーを押してください... "
    )
    context.close()
    playwright.stop()
    print("ログイン状態を保存しました。")


def ensure_place_detail_open(page) -> None:
    """検索結果が一覧表示の場合、先頭候補のお店を開いて詳細パネルを表示する。"""
    if "/maps/place/" in page.url:
        return
    # クエリが一意な候補にヒットすると、一覧を経由せず直接詳細ページへ
    # リダイレクトされることがある。その遷移が完了するのを少し待ってから
    # 一覧用ロケータの待機にフォールバックする。
    try:
        page.wait_for_url(re.compile(r"/maps/place/"), timeout=5_000)
        return
    except PlaywrightTimeoutError:
        pass
    first_result = page.locator('a[href*="/maps/place/"]').first
    first_result.wait_for(state="visible", timeout=UI_TIMEOUT_MS)
    first_result.click()
    page.wait_for_url(re.compile(r"/maps/place/"), timeout=UI_TIMEOUT_MS)
    page.wait_for_timeout(1_000)


def click_save_button(page) -> None:
    save_button = page.locator(
        'button[aria-label*="保存"], button[aria-label*="Save"], button[data-value="Save"]'
    ).first
    save_button.wait_for(state="visible", timeout=UI_TIMEOUT_MS)
    save_button.click()


def toggle_list(page, list_name: str) -> None:
    # 「リストに保存」ポップアップはmodal dialogではなくメニュー形式で表示される。
    heading = page.get_by_text("リストに保存", exact=True).first
    heading.wait_for(state="visible", timeout=UI_TIMEOUT_MS)

    existing = page.get_by_text(list_name, exact=True).first
    try:
        existing.wait_for(state="visible", timeout=3_000)
        existing.click()
        return
    except PlaywrightTimeoutError:
        pass

    create_button = page.get_by_role(
        "button", name=re.compile("新しいリスト|Create new list")
    ).first
    create_button.wait_for(state="visible", timeout=UI_TIMEOUT_MS)
    create_button.click()

    name_input = page.get_by_role("textbox").first
    name_input.wait_for(state="visible", timeout=UI_TIMEOUT_MS)
    name_input.fill(list_name)

    confirm_button = page.get_by_role("button", name=re.compile("作成|Create")).first
    confirm_button.wait_for(state="visible", timeout=UI_TIMEOUT_MS)
    confirm_button.click()


def bookmark(query: str, list_name: str, headless: bool) -> None:
    playwright, context = open_browser(headless=headless)
    page = context.pages[0] if context.pages else context.new_page()

    target = query if is_url(query) else build_search_url(query)
    page.goto(target, timeout=NAV_TIMEOUT_MS)
    page.wait_for_timeout(2_000)

    try:
        ensure_place_detail_open(page)
        click_save_button(page)
        toggle_list(page, list_name)
        page.wait_for_timeout(1_000)
        page.keyboard.press("Escape")
    except PlaywrightTimeoutError as exc:
        print(f"操作に失敗しました: {exc}", file=sys.stderr)
        print(f"現在のURL: {page.url}", file=sys.stderr)
        debug_path = Path("/tmp/google-map-bookmark-debug.png")
        page.screenshot(path=str(debug_path))
        print(f"デバッグ用スクリーンショット: {debug_path}", file=sys.stderr)
        print(
            "Google Maps側のUIが変わった可能性があります。"
            "--headlessを外して手動確認してください。",
            file=sys.stderr,
        )
        context.close()
        playwright.stop()
        sys.exit(1)

    context.close()
    playwright.stop()
    print(f"「{query}」を「{list_name}」に保存しました。")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="店名またはGoogle MapsのURLからGoogle Mapsのリストに保存する"
    )
    parser.add_argument("query", nargs="?", help="店名 または Google MapsのURL")
    parser.add_argument(
        "-l",
        "--list",
        dest="list_name",
        default=DEFAULT_LIST,
        help=f"保存先リスト名 (デフォルト: {DEFAULT_LIST})",
    )
    parser.add_argument(
        "--headless", action="store_true", help="ヘッドレスモードで実行する"
    )
    parser.add_argument(
        "--login", action="store_true", help="初回ログイン用にブラウザを開く"
    )
    args = parser.parse_args()

    if args.login:
        do_login()
        return

    if not args.query:
        parser.error(
            "queryを指定してください（店名またはURL）。"
            "初回ログインは --login を使用してください。"
        )

    bookmark(args.query, args.list_name, args.headless)


if __name__ == "__main__":
    main()
