import { useEffect, useState } from "react";
import {
  Action,
  ActionPanel,
  Clipboard,
  Color,
  Icon,
  List,
  LocalStorage,
  Toast,
  getPreferenceValues,
  popToRoot,
  showToast,
} from "@vicinae/api";
import { getPeers, sendClipboardTo, type Peer } from "./lib/tailscale";

interface Preferences {
  favorites: string;
  showOffline: boolean;
}

const LAST_TARGET_KEY = "lastTarget";

export default function Command() {
  const preferences = getPreferenceValues<Preferences>();
  const favorites = preferences.favorites
    .split(",")
    .map((name) => name.trim())
    .filter(Boolean);

  const [clipboardText, setClipboardText] = useState<string | null>(null);
  const [peers, setPeers] = useState<Peer[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lastTarget, setLastTarget] = useState<string | null | undefined>(undefined);

  useEffect(() => {
    Clipboard.readText().then(async (text) => {
      if (!text) {
        await showToast({ style: Toast.Style.Failure, title: "Clipboard is empty" });
      }
      setClipboardText(text);
    });

    getPeers()
      .then(setPeers)
      .catch((err: Error) => setError(err.message));

    LocalStorage.getItem<string>(LAST_TARGET_KEY).then((value) => setLastTarget(value ?? null));
  }, []);

  async function handleSend(hostName: string) {
    if (!clipboardText) {
      return;
    }

    const toast = await showToast({ style: Toast.Style.Animated, title: `Sending to ${hostName}...` });

    try {
      await sendClipboardTo(hostName, clipboardText);
      await LocalStorage.setItem(LAST_TARGET_KEY, hostName);
      toast.style = Toast.Style.Success;
      toast.title = `Sent to ${hostName}`;
      await popToRoot();
    } catch (err) {
      toast.style = Toast.Style.Failure;
      toast.title = `Failed to send to ${hostName}`;
      toast.message = (err as Error).message;
    }
  }

  if (clipboardText === "") {
    return (
      <List>
        <List.EmptyView title="Clipboard is empty" icon={Icon.CopyClipboard} />
      </List>
    );
  }

  if (error) {
    return (
      <List>
        <List.EmptyView title="Tailscaleの取得に失敗しました" description={error} icon={Icon.Warning} />
      </List>
    );
  }

  const isLoading = clipboardText === null || peers === null || lastTarget === undefined;

  const visiblePeers = (peers ?? []).filter((peer) => preferences.showOffline || peer.online);

  const lastTargetPeer = visiblePeers.find((peer) => peer.hostName === lastTarget);
  const remainingPeers = visiblePeers.filter((peer) => peer.hostName !== lastTarget);

  const favoritePeers = favorites
    .map((name) => remainingPeers.find((peer) => peer.hostName === name))
    .filter((peer): peer is Peer => peer !== undefined);

  const favoriteNames = new Set(favoritePeers.map((peer) => peer.hostName));
  const otherPeers = remainingPeers
    .filter((peer) => !favoriteNames.has(peer.hostName))
    .sort((a, b) => a.hostName.localeCompare(b.hostName));

  return (
    <List isLoading={isLoading}>
      {lastTargetPeer && <List.Section title="最近使った端末">{renderItem(lastTargetPeer, handleSend)}</List.Section>}
      {favoritePeers.length > 0 && (
        <List.Section title="お気に入り">{favoritePeers.map((peer) => renderItem(peer, handleSend))}</List.Section>
      )}
      {otherPeers.length > 0 && (
        <List.Section title="その他">{otherPeers.map((peer) => renderItem(peer, handleSend))}</List.Section>
      )}
    </List>
  );
}

function renderItem(peer: Peer, onSend: (hostName: string) => void) {
  return (
    <List.Item
      key={peer.hostName}
      id={peer.hostName}
      title={peer.hostName}
      subtitle={peer.online ? "Online" : "Offline"}
      icon={{ source: Icon.CircleFilled, tintColor: peer.online ? Color.Green : Color.SecondaryText }}
      actions={
        <ActionPanel>
          <Action title="Send Clipboard" icon={Icon.Upload} onAction={() => onSend(peer.hostName)} />
        </ActionPanel>
      }
    />
  );
}
