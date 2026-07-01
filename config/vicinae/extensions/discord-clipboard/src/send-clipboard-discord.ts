import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Clipboard, Toast, getPreferenceValues, showToast } from "@vicinae/api";

const execFileAsync = promisify(execFile);

interface Preferences {
  channel: string;
}

export default async function Command() {
  const { channel } = getPreferenceValues<Preferences>();

  const text = await Clipboard.readText();
  if (!text) {
    await showToast({ style: Toast.Style.Failure, title: "Clipboard is empty" });
    return;
  }

  try {
    await execFileAsync("discord_cli", ["send", "-m", text, "-c", channel]);
    await showToast({ style: Toast.Style.Success, title: "Sent to Discord" });
  } catch (error) {
    const err = error as Error & { stderr?: string; code?: string };

    if (err.code === "ENOENT") {
      await showToast({
        style: Toast.Style.Failure,
        title: "discord_cli command not found",
      });
      return;
    }

    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to send to Discord",
      message: err.stderr?.trim() || err.message,
    });
  }
}
