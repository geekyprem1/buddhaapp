import { randomUUID } from "node:crypto";
import { getStorage } from "firebase-admin/storage";

/**
 * Save a derivative object beside the original and return a Firebase
 * download URL (token-based, same shape `getDownloadURL()` produces on the
 * client) so the content doc can reference it directly.
 */
export async function saveDerivative(
  bucketName: string,
  path: string,
  data: Buffer,
  contentType: string,
): Promise<string> {
  const token = randomUUID();
  const bucket = getStorage().bucket(bucketName);
  const file = bucket.file(path);
  await file.save(data, {
    resumable: false,
    contentType,
    metadata: {
      contentType,
      cacheControl: "public, max-age=31536000, immutable",
      metadata: {
        // Marks Function-generated derivatives so onMediaUpload never
        // reprocesses its own output.
        derived: "true",
        firebaseStorageDownloadTokens: token,
      },
    },
  });
  return downloadUrl(bucketName, path, token);
}

export function downloadUrl(
  bucketName: string,
  path: string,
  token: string,
): string {
  const encoded = encodeURIComponent(path);
  return (
    `https://firebasestorage.googleapis.com/v0/b/${bucketName}` +
    `/o/${encoded}?alt=media&token=${token}`
  );
}

/** Download an existing object into memory. */
export async function readObject(
  bucketName: string,
  path: string,
): Promise<Buffer> {
  const [buffer] = await getStorage().bucket(bucketName).file(path).download();
  return buffer;
}

/**
 * Return a Firebase download URL for an existing object, reusing the token the
 * client SDK already set on upload, or writing one if absent. Used for audio,
 * whose original file is itself the playable media (no transcode).
 */
export async function ensureDownloadUrl(
  bucketName: string,
  path: string,
): Promise<string> {
  const file = getStorage().bucket(bucketName).file(path);
  const [meta] = await file.getMetadata();
  const existing = meta.metadata?.firebaseStorageDownloadTokens;
  let token = existing ? String(existing).split(",")[0] : "";
  if (!token) {
    token = randomUUID();
    await file.setMetadata({
      metadata: { firebaseStorageDownloadTokens: token },
    });
  }
  return downloadUrl(bucketName, path, token);
}
