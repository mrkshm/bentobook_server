# Diagnosing and Fixing the Image Upload Race Condition

> This document details a subtle but critical race condition in the client-side image upload process that affected real iOS devices while working correctly in development environments.

---

## The Problem

When uploading images on a real iOS device, the upload progress bar would reach 100%, but the process would hang indefinitely, never navigating to the next screen. This issue did not occur on desktop web browsers or on the iOS simulator.

The server logs showed that the direct upload was being initiated correctly, but the final `POST` request to the `ImagesController#create` action to attach the uploaded files was never received.

## Root Cause Analysis: A Client-Side Race Condition

The bug was not on the server, but entirely within the client-side `app/frontend/controllers/image_upload_controller.js`. The issue stemmed from a misunderstanding of the Active Storage `DirectUpload` lifecycle.

The process involves two distinct, asynchronous steps:

1.  **The `create` Call:** A quick API request to the Rails server. The server creates a blob record in the database and returns a `signed_id` that authorizes the client to upload a file directly to the storage service (e.g., S3).
2.  **The XHR Upload:** The actual `PUT` request that sends the file's data from the client to the storage service.

The original JavaScript code was flawed: it was submitting the form as soon as the first step (`create`) completed, without waiting for the second, much longer step (the XHR upload) to finish.

### Why It Failed Only on Real Devices

-   **On Localhost / Simulator:** The network connection is extremely fast and stable. The S3 upload (Step 2) was so quick that it almost always finished before the server could even process the final form submission. The race condition existed, but the S3 upload always won.
-   **On a Real iOS Device (Cellular/Wi-Fi):** Real-world networks have higher latency. The `create` call (Step 1) would complete quickly, but the actual file upload (Step 2) would take several seconds. The buggy JavaScript would submit the form immediately after Step 1, and the Rails controller would then try to find the blob on S3. Since the file hadn't arrived yet, the process would hang, leaving the user stuck.

## Current Status: Resolved

The issue has been fixed by properly implementing the `DirectUpload` delegate pattern and fixing several related issues in the image upload process.

### Solution: Proper Implementation of DirectUpload Lifecycle

1. **Fixed Promise Resolution**: The original code had a race condition in how it resolved promises. The fix ensures that the promise only resolves after the S3 upload is complete, not just when the blob record is created.

2. **Simplified DirectUpload Delegate**: The `directUploadWillStoreFileWithXHR` method was simplified to only handle progress tracking, letting the DirectUpload library handle the success/error callbacks internally.

3. **Prevented Multiple Uploads**: Added an `isUploading` flag to prevent multiple simultaneous uploads from being triggered.

4. **Fixed Form Submission**: The form submission process was fixed to:
   - Clear the file input before submission to prevent sending file data
   - Use the form's built-in FormData after clearing the file input
   - Submit the form directly without triggering the submit event again
   - Remove the locale parameter from the form URL to prevent issues

5. **Added Error Handling**: Added proper error handling and timeout protection to prevent infinite waiting.

### Key Code Changes

```javascript
// 1. Fixed uploadFile method to properly handle the DirectUpload lifecycle
uploadFile(file) {
  return new Promise((resolve, reject) => {
    const upload = new DirectUpload(file, this.directUploadUrlValue, this)
    
    // Add timeout protection
    const timeout = setTimeout(() => {
      reject(new Error(`Upload timeout for ${file.name}`))
    }, 60000)
    
    upload.create((error, blob) => {
      clearTimeout(timeout)
      if (error) {
        reject(error)
      } else {
        resolve(blob)
      }
    })
  })
}

// 2. Simplified directUploadWillStoreFileWithXHR to only handle progress
directUploadWillStoreFileWithXHR(request) {
  request.upload.addEventListener("progress", event => {
    if (event.lengthComputable) {
      const progress = (event.loaded / event.total) * 100
      this.updateProgressBar(progress)
    }
  })
}

// 3. Fixed form submission to avoid race conditions
async submitForm(event) {
  event.preventDefault()
  
  // Prevent multiple uploads
  if (this.isUploading) return
  
  this.isUploading = true
  // ... upload logic ...
  
  // Clear file input and submit form
  this.inputTarget.value = ''
  const formData = new FormData(this.element)
  
  // Submit form using fetch to have more control
  const response = await fetch(this.element.action, {
    method: 'POST',
    body: formData,
    headers: { 'X-Requested-With': 'XMLHttpRequest' }
  })
}
```

This solution ensures that the form is only submitted after all files have been successfully uploaded to S3, and that the server receives only the signed_ids of the uploaded blobs, not the actual file data.
