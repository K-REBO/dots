import { Clipboard, Toast, getPreferenceValues, showToast } from "@vicinae/api";
import { sendClipboardTo } from "./lib/tailscale";

interface Preferences {
  target: string;
}

export default async function Command() {
  const { target } = getPreferenceValues<Preferences>();

  const text = await Clipboard.readText();
  if (!text) {
    await showToast({ style: Toast.Style.Failure, title: "Clipboard is empty" });
    return;
  }

  try {
    await sendClipboardTo(target, text);
    await showToast({ style: Toast.Style.Success, title: `Sent to ${target}` });
  } catch (err) {
    await showToast({
      style: Toast.Style.Failure,
      title: `Failed to send to ${target}`,
      message: (err as Error).message,
    });
  }
}
