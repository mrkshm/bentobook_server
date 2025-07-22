# Development Strategy & Roadmap

> This document outlines the prioritized roadmap for the next phase of BentoBook's development. The order is designed to deliver the most impactful changes first, focusing on stability and performance before moving on to new features.

---

## The Prioritized Roadmap

1.  **Fix Login Session Length**
2.  **Implement Image Optimization Strategy**
3.  **Refactor Contacts & Profile to use Inline Editing**
4.  **Implement Native Header Styling Bridge**
5.  **Develop Maps & Distance-Based Features**

---

## Rationale & Staging

This order follows a strategic progression from foundational fixes to feature development:
**Retention → Performance → Consistency → Polish → New Features**

### 1. Fix Login Session Length

-   **Priority:** Highest
-   **Focus:** User Retention
-   **Reasoning:** This is the most critical user experience issue. Frequent, unnecessary logins are a major source of frustration and will cause users to abandon the app. Before enhancing the app, we must ensure the fundamental experience of accessing it is seamless and stable. This is the "leakiest bucket" and must be plugged first.

### 2. Implement Image Optimization Strategy

-   **Priority:** High
-   **Focus:** Performance & Cost
-   **Reasoning:** This is a foundational improvement that benefits the entire application. A comprehensive image optimization strategy will make the app faster and more pleasant for every user on every screen. It also has a direct and significant impact on long-term operational costs. All future features will be built on this faster, more efficient foundation.

### 3. Inline Editing for Contacts & Profile

-   **Priority:** Medium
-   **Focus:** UX Consistency & Quality
-   **Reasoning:** The app currently has two different editing patterns: a modern, inline style for core features (Restaurants, Visits) and a standard, full-page form for secondary ones (Contacts, Profile). This creates a disjointed experience. Unifying the editing patterns to be consistently inline will make the entire application feel more professional, cohesive, and polished.

### 4. Native Header Styling Bridge

-   **Priority:** Medium-Low
-   **Focus:** Polish
-   **Reasoning:** This is a high-impact visual fix. While less critical than the preceding issues, making the header react to theme changes and feel truly native provides a great deal of professional polish for a relatively low effort. It’s the perfect task to tackle after the major foundational work is complete, making the app feel seamless before diving into a big new feature.

### 5. Develop Maps & Distance-Based Features

-   **Priority:** Future Feature
-   **Focus:** New Value & Engagement
-   **Reasoning:** This is an exciting, value-adding feature. It's intentionally placed last in this roadmap because it should be built on a solid foundation. By the time we start this, the app will be stable, fast, consistent, and polished. That is the ideal state from which to introduce a brand-new discovery feature that will drive user engagement.
