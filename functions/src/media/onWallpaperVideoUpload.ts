import { onObjectFinalized } from "firebase-functions/v2/storage";
import { logger } from "firebase-functions/v2";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import sharp from "sharp";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { randomUUID } from "node:crypto";
import { promises as fs } from "node:fs";
import ffmpegPath from "ffmpeg-static";
import { ensureDownloadUrl, saveDerivative } from "../lib/storage";

const execFileAsync = promisify(execFile);

const THUMB_TARGET_BYTES = 40 * 1024;
const THUMB_WIDTH = 320;
const POSTER_MAX_WIDTH = 1440;

/**
 * Auto-generates a still thumbnail + poster from a live-wallpaper VIDEO upload.
 *
 * Fires on `wallpapers/{itemId}/video.*`. It grabs a frame ~0.5s in with
 * ffmpeg, encodes `full.webp` (poster) + `thumb.webp` (≤40 KB), and patches
 * the doc so the grid/reel have a still and the item is marked live — no
 * manual poster upload needed. Also self-heals `wallpaper.videoUrl` /
 * `wallpaper.kind` from the actual uploaded object.
 */
export const onWallpaperVideoUpload = onObjectFinalized(
  { region: "asia-south1", memory: "1GiB", timeoutSeconds: 180 },
  async (event) => {
    const object = event.data;
    const name = object.name ?? "";
    const bucket = object.bucket;

    if (object.metadata?.derived === "true") return;
    const parts = name.split("/");
    if (parts.length !== 3) return;
    const [collection, itemId, filename] = parts;
    if (collection !== "wallpapers") return;
    if (!filename.startsWith("video.")) return;

    const work = join(tmpdir(), randomUUID());
    await fs.mkdir(work, { recursive: true });
    const localVideo = join(work, filename);
    const framePng = join(work, "frame.png");

    try {
      await getStorage()
        .bucket(bucket)
        .file(name)
        .download({ destination: localVideo });

      if (!ffmpegPath) throw new Error("ffmpeg binary unavailable");
      // `-ss 0.5` before `-i` seeks fast; grab a single frame.
      await execFileAsync(ffmpegPath, [
        "-ss",
        "0.5",
        "-i",
        localVideo,
        "-frames:v",
        "1",
        "-y",
        framePng,
      ]);

      const frame = await fs.readFile(framePng);
      const meta = await sharp(frame).metadata();

      const posterBuffer = await sharp(frame)
        .rotate()
        .resize({ width: POSTER_MAX_WIDTH, withoutEnlargement: true })
        .webp({ quality: 82 })
        .toBuffer();
      const thumbBuffer = await encodeThumb(frame);

      const posterPath = `${collection}/${itemId}/full.webp`;
      const thumbPath = `${collection}/${itemId}/thumb.webp`;
      const [posterUrl, thumbUrl, videoUrl] = await Promise.all([
        saveDerivative(bucket, posterPath, posterBuffer, "image/webp"),
        saveDerivative(bucket, thumbPath, thumbBuffer, "image/webp"),
        ensureDownloadUrl(bucket, name),
      ]);

      const width = meta.width ?? null;
      const height = meta.height ?? null;
      const wallpaper: Record<string, unknown> = {
        kind: "live",
        videoUrl,
        posterUrl,
      };
      if (width && height) {
        wallpaper.width = width;
        wallpaper.height = height;
        wallpaper.orientation = height >= width ? "portrait" : "landscape";
      }

      // `set(..., {merge:true})` deep-merges the wallpaper map, so it never
      // wipes fields the admin form already wrote (orientation, etc.).
      await getFirestore()
        .collection(collection)
        .doc(itemId)
        .set(
          {
            thumbUrl,
            mediaUrl: posterUrl,
            storagePath: posterPath,
            wallpaper,
            mediaProcessedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    } catch (err) {
      logger.error("onWallpaperVideoUpload failed", {
        path: name,
        error: err instanceof Error ? err.message : String(err),
      });
      throw err;
    } finally {
      await fs.rm(work, { recursive: true, force: true }).catch(() => {});
    }
  },
);

/** Step quality/width down until the WebP thumbnail fits under 40 KB. */
async function encodeThumb(frame: Buffer): Promise<Buffer> {
  const attempts: Array<{ width: number; quality: number }> = [
    { width: THUMB_WIDTH, quality: 72 },
    { width: THUMB_WIDTH, quality: 55 },
    { width: 256, quality: 45 },
    { width: 200, quality: 38 },
  ];
  let smallest: Buffer | null = null;
  for (const attempt of attempts) {
    const out = await sharp(frame)
      .rotate()
      .resize({ width: attempt.width, withoutEnlargement: true })
      .webp({ quality: attempt.quality })
      .toBuffer();
    if (out.length <= THUMB_TARGET_BYTES) return out;
    if (!smallest || out.length < smallest.length) smallest = out;
  }
  return smallest as Buffer;
}
