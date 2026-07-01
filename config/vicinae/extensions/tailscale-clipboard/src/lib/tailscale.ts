import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { randomUUID } from "node:crypto";
import { writeFile, unlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

const execFileAsync = promisify(execFile);

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
