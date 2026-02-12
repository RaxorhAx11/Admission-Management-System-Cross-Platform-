# Fix Firebase Storage CORS (Web Upload from localhost)

The error **"blocked by CORS policy: Response to preflight request doesn't pass access control check"** when submitting the admission form on **Flutter web** (e.g. `http://localhost:61422`) happens because your Firebase Storage bucket does not allow requests from that origin. CORS must be configured on the **bucket** (Google Cloud), not in your app code.

## One-time setup

### 1. Install Google Cloud SDK (if needed)

- Download: https://cloud.google.com/sdk/docs/install  
- Or use **Google Cloud Shell** in the browser: https://console.cloud.google.com → click the Cloud Shell icon (no local install needed).

### 2. Authenticate

```bash
gcloud auth login
```

Use the same Google account that owns the Firebase project `admission-management-sys-a89a3`.

### 3. Apply CORS to your Storage bucket

From the **project root** (where `storage.cors.json` is), run **one** of these (bucket name may vary):

**Option A – gsutil (classic)**

```bash
gsutil cors set storage.cors.json gs://admission-management-sys-a89a3.appspot.com
```

**Option B – gcloud (new)**

```bash
gcloud storage buckets update gs://admission-management-sys-a89a3.appspot.com --cors-file=storage.cors.json
```

If you see "bucket not found", check the exact bucket name:

- Firebase Console → **Storage** → tab **Files** → look at the bucket name in the UI or in **Project settings** → **General** → **Your apps** → web app → `storageBucket`.  
- For Google Cloud Storage, the bucket is often `gs://YOUR_PROJECT_ID.appspot.com`. If your `storageBucket` is `admission-management-sys-a89a3.firebasestorage.app`, try that as well:

```bash
gsutil cors set storage.cors.json gs://admission-management-sys-a89a3.firebasestorage.app
```

### 4. Test

Restart the Flutter web app if it’s already running, then submit the admission form again from the browser. The upload should succeed without CORS errors.

## Restricting origins later (optional)

The included `storage.cors.json` uses `"origin": ["*"]` so any origin (including localhost on any port) can call Storage. For production you can replace it with a list of allowed origins, for example:

```json
"origin": [
  "http://localhost:61422",
  "http://localhost:8080",
  "https://yourdomain.com"
]
```

Then run the same `gsutil cors set` or `gcloud storage buckets update` command again.
