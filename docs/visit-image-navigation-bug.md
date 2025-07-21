# Investigating the Visit Image Navigation Bug

> This document details the investigation into a subtle but jarring navigation bug affecting the image management workflow for Visits in the Hotwire Native application.

---

## 1. The Problem

When a user adds or deletes a photo from a **Visit**, the action succeeds, and the modal sheet dismisses correctly. However, the application then performs an additional, unnecessary navigation to the `visits#show` page.

This pushes a duplicate of the page onto the native navigation stack, resulting in an unwanted "Back" button that leads to the same screen the user is already on.

This behavior does **not** occur when performing the same actions for a **Restaurant**.

## 2. The Investigation: What We Ruled Out

The investigation was complex because the server-side code for both Restaurants and Visits is nearly identical. We systematically ruled out several potential causes:

-   **Incorrect Redirects:** We initially suspected the Rails `redirect_to` call in the `ImagesController` was generating a slightly different URL (e.g., with extra parameters), causing Hotwire to see it as a new page. This was proven false; the redirect URL was correct.

-   **Nested vs. Canonical Routes:** We hypothesized that Visits were being accessed via a nested route (e.g., `/restaurants/1/visits/2`) and the redirect was to a canonical route (`/visits/2`), causing a URL mismatch. A review of `config/routes.rb` confirmed this was false; Visits are a top-level resource.

-   **Redirect Chains:** We considered the possibility that the `ImagesController` was redirecting to `VisitsController#edit`, which was then performing a second redirect to `VisitsController#show`. An analysis of the `edit` views and controllers showed no such chain exists.

-   **View Template Differences:** We looked for minor differences in the view templates, such as parameters passed to partials or different `meta` tags, that might change Turbo Native's behavior. No meaningful differences were found.

## 3. The Root Cause: Client-Side Navigation Control

The breakthrough came from analyzing the Stimulus JavaScript controllers that power the image management UI. The final navigation is **not** handled by a standard Rails redirect, but by client-side JavaScript.

### Deletion Flow (`image-selector_controller.js`)

When deleting images, the controller makes an API call and, on success, explicitly tells Turbo how to navigate:

```javascript
// in image-selector_controller.js
const redirectPath = this.getRedirectPath() // e.g., "/visits/123"

Turbo.visit(redirectPath, { 
  action: "replace", // Explicitly tells Turbo to replace the page
  flash: { notice: successMessage }
})
```

This code is **correct**. The `action: "replace"` directive should prevent a new page from being pushed to the stack. The fact that the bug still occurs for Visits points to a configuration issue in the native app wrapper, where the `/visits/...` path is not being treated as "replaceable" in the same way `/restaurants/...` is.

### Creation Flow (`image-upload_controller.js`)

When adding new images, the controller waits for the direct uploads to finish and then submits the form to the Rails controller:

```javascript
// in image-upload_controller.js

// ... after uploads are complete ...
this.element.requestSubmit()
```

This triggers a standard form submission. The Rails `ImagesController` responds with a `302 Redirect`. Crucially, the JavaScript **does not intercept this redirect** to control the navigation. It allows Turbo Drive to handle it with its **default behavior, which is a "push" navigation**.

This is the direct cause of the bug on image creation.

## 4. Current Hypothesis & Path to Resolution

The navigation bug is the result of two separate client-side issues that produce the same symptom:

1.  **Creation Bug:** The `image-upload_controller.js` is missing the logic to perform a `Turbo.visit` with `{ action: "replace" }`. It relies on a standard form submission, which defaults to a "push" navigation.

2.  **Deletion Bug:** The `image-selector_controller.js` is implemented correctly, but the native application wrapper is likely not configured to honor the `{ action: "replace" }` directive for the `/visits/` path, causing it to fall back to a "push".

### Recommended Next Steps

1.  **Fix the Creation Flow:** Modify `image-upload_controller.js` to handle the form submission response. Instead of letting Turbo perform a default navigation, it should manually call `Turbo.visit(redirectUrl, { action: "replace" })`, mirroring the logic in `image-selector_controller.js`.

2.  **Investigate Native Configuration:** Review the Hotwire Native configuration (e.g., in `configurations_controller.rb` or the native Swift/Kotlin code) to understand why the `/visits/` path might be treated differently from the `/restaurants/` path, causing it to ignore the `replace` action.
