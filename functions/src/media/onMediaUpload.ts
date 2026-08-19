import { onObjectFinalized } from "firebase-functions/v2/storage";
import { logger } from "firebase-functions/v2";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import sharp from "sharp";
import { parseBuffer } from "music-metadata";
import {
  CONTENT_MEDIA_KIND,
  isContentCollection,
  type ContentCollection,
} from "../lib/content";
import { ensureDownloadUrl, readObject, saveDerivative } from "../lib/storage";

const THUMB_TARGET_BYTES = 40 * 1024; // T1.10: thumbnail ≤ 40 KB
const THUMB_WIDTH = 320;
const FULL_MAX_WIDTH = 1440;

/**
 * `onMediaUpload` (Architecture §8, T1.10). Fires when an admin finalises an
 * original upload at `{collection}/{itemId}/original.{ext}`:
 *   - image → WebP `full.webp` + `thumb.webp` (≤40 KB) beside it, doc patched
 *     with `mediaUrl` / `thumbUrl` / `storagePath` and image dimensions.
 *   - audio → duration read from the file header, doc patched with
 *     `audio.durationSec`.
 * Only `original.*` objects are processed; generated derivatives carry a
 * `derived` metadata marker and are skipped, so the trigger never loops.
 */
export const onMediaUpload = onObjectFinalized(
  { region: "asia-south1", memory: "512MiB", timeoutSeconds: 120 },
  async (event) => {
    const object = event.data;
    const name = object.name ?? "";
    const bucket = object.bucket;

    if (object.metadata?.derived === "true") return;

    const parts = name.split("/");
    if (parts.length !== 3) return;
    const [collection, itemId, filename] = parts;
    if (!isContentCollection(collection)) return;
    if (!filename.startsWith("original.")) return;

    const kind = CONTENT_MEDIA_KIND[collection as ContentCollection];
    try {
      const buffer = await readObject(bucket, name);
      if (kind === "image") {
        await processImage(bucket, collection, itemId, buffer);
      } else {
        await processAudio(bucket, name, collection, itemId, buffer);
      }
    } catch (err) {
      logger.error("onMediaUpload failed", {
        path: name,
        error: err instanceof Error ? err.message : String(err),
      });
      throw err;
    }
  },
);

async function processImage(
  bucket: string,
  collection: string,
  itemId: string,
  original: Buffer,
): Promise<void> {
  const meta = await sharp(original).metadata();

  const fullBuffer = await sharp(original)
    .rotate()
    .resize({ width: FULL_MAX_WIDTH, withoutEnlargement: true })
    .webp({ quality: 82 })
    .toBuffer();

  const thumbBuffer = await encodeThumb(original);

  const fullPath = `${collection}/${itemId}/full.webp`;
  const thumbPath = `${collection}/${itemId}/thumb.webp`;
  const [fullUrl, thumbUrl] = await Promise.all([
    saveDerivative(bucket, fullPath, fullBuffer, "image/webp"),
    saveDerivative(bucket, thumbPath, thumbBuffer, "image/webp"),
  ]);

  const width = meta.width ?? null;
  const height = meta.height ?? null;
  const patch: Record<string, unknown> = {
    mediaUrl: fullUrl,
    thumbUrl,
    storagePath: fullPath,
    mediaProcessedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (collection === "wallpapers" && width && height) {
    patch.wallpaper = {
      width,
      height,
      orientation: height >= width ? "portrait" : "landscape",
    };
  }
  await getFirestore().collection(collection).doc(itemId).set(patch, {
    merge: true,
  });
}

/** Step quality/width down until the WebP thumbnail fits under 40 KB. */
async function encodeThumb(original: Buffer): Promise<Buffer> {
  const attempts: Array<{ width: number; quality: number }> = [
    { width: THUMB_WIDTH, quality: 72 },
    { width: THUMB_WIDTH, quality: 55 },
    { width: 256, quality: 45 },
    { width: 200, quality: 38 },
  ];
  let smallest: Buffer | null = null;
  for (const attempt of attempts) {
    const out = await sharp(original)
      .rotate()
      .resize({ width: attempt.width, withoutEnlargement: true })
      .webp({ quality: attempt.quality })
      .toBuffer();
    if (out.length <= THUMB_TARGET_BYTES) return out;
    if (!smallest || out.length < smallest.length) smallest = out;
  }
  return smallest as Buffer;
}

async function processAudio(
  bucket: string,
  name: string,
  collection: string,
  itemId: string,
  buffer: Buffer,
): Promise<void> {
  let durationSec: number | null = null;
  try {
    const parsed = await parseBuffer(buffer);
    if (typeof parsed.format.duration === "number") {
      durationSec = Math.round(parsed.format.duration);
    }
  } catch (err) {
    logger.warn("Could not read audio duration", {
      collection,
      itemId,
      error: err instanceof Error ? err.message : String(err),
    });
  }

  // The original audio IS the playable media (no transcode), so point the
  // doc's mediaUrl at it. This makes bulk-uploaded audio playable without the
  // admin having to re-enter a URL.
  const mediaUrl = await ensureDownloadUrl(bucket, name);

  const patch: Record<string, unknown> = {
    mediaUrl,
    storagePath: name,
    mediaProcessedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (durationSec != null) {
    patch.audio = { durationSec };
  }

  await getFirestore().collection(collection).doc(itemId).set(patch, {
    merge: true,
  });
}
