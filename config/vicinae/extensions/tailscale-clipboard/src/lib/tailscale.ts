import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { randomUUID } from "node:crypto";
import { writeFile, unlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

const execFileAsync = promisify(execFile);

export interface Peer {
  hostName: string;
  dnsName: string;
  online: boolean;
}

interface TailscaleStatus {
  Peer?: Record<
    string,
    {
      HostName: string;
      DNSName: string;
      Online: boolean;
    }
  >;
}

export async function getPeers(): Promise<Peer[]> {
  let stdout: string;

  try {
    ({ stdout } = await execFileAsync("tailscale", ["status", "--json"]));
  } catch (error) {
    const err = error as NodeJS.ErrnoException & { stderr?: string };

    if (err.code === "ENOENT") {
      throw new Error("tailscaleコマンドが見つかりません。Tailscaleをインストールしてください。");
    }

    throw new Error(err.stderr?.trim() || err.message);
  }

  const status: TailscaleStatus = JSON.parse(stdout);

  return Object.values(status.Peer ?? {}).map((peer) => ({
    // HostNameはMagicDNSが無効な端末では重複しうる(例: "localhost")ため、
    // DNSNameの先頭ラベル(MagicDNSショートネーム)をHostNameの代わりに使う
    hostName: peer.DNSName.replace(/\.$/, "").split(".")[0] || peer.HostName,
    dnsName: peer.DNSName,
    online: peer.Online,
  }));
}

export async function sendClipboardTo(hostName: string, text: string): Promise<void> {
  const tmpFile = join(tmpdir(), `vicinae-clipboard-${randomUUID()}.txt`);

  await writeFile(tmpFile, text, "utf-8");

  try {
    await execFileAsync("tailscale", ["file", "cp", tmpFile, `${hostName}:`]);
  } catch (error) {
    const err = error as Error & { stderr?: string };
    throw new Error(err.stderr?.trim() || err.message);
  } finally {
    await unlink(tmpFile).catch(() => {});
  }
}
