# Implementation Plan

## Overview

Implement the requirements in five ordered waves: shared presentation, legal content, Hosting configuration, validation, then production-only deployment and verification.

## Task Dependency Graph

```json
{
  "waves": [
    { "wave": 1, "tasks": ["1.1", "1.2"] },
    { "wave": 2, "tasks": ["2.1", "2.2", "2.3", "2.4"] },
    { "wave": 3, "tasks": ["3.1"] },
    { "wave": 4, "tasks": ["3.2"] },
    { "wave": 5, "tasks": ["4.1"] },
    { "wave": 6, "tasks": ["5.1"] },
    { "wave": 7, "tasks": ["5.2"] }
  ]
}
```

Tasks 2.1–2.4 may proceed after the shared page structure/style is available. Deployment cannot begin until all content, routing, and validation tasks complete.

## Notes

- Production mutations are limited to Firebase Hosting target `public` in `dhamma-path-prod`.
- Existing tests may be run for confidence; no new automated tests are required for these static pages.
- A failed deployment or route verification stops execution rather than broadening deployment scope.

## Tasks

- [x] 1. Build the shared static-site presentation
  - [x] 1.1 Replace the placeholder homepage with the Dhamma Path public landing page
    - Add semantic header, navigation, feature overview, policy cards, support CTA, and footer.
    - Remove the private Admin link and unshipped supporter-ID claim.
    - _Requirements: 1.1, 1.3, 1.4, 6.1–6.6_
  - [x] 1.2 Add the shared responsive stylesheet and accessibility states
    - Implement the ivory/maroon/gold visual system, mobile-first layout, focus visibility, contrast, and reduced-motion behavior.
    - Avoid remote fonts, scripts, trackers, and unnecessary assets.
    - _Requirements: 6.1–6.6_

- [x] 2. Publish the legal and support content
  - [x] 2.1 Create the Privacy Policy page
    - Describe implemented authentication, profile data, preferences, alarms, contact messages, Firebase services, permissions, local-only status photos, retention, security, and choices.
    - Use `dhammapathai@gmail.com` for privacy inquiries and avoid inactive-service or legal-entity claims.
    - _Requirements: 2.1–2.10, 7.1–7.6_
  - [x] 2.2 Create the Terms and Conditions page
    - Cover account responsibility, respectful/personal use, prohibited conduct, licensed content, service limitations, third parties, changes, and contact.
    - _Requirements: 3.1–3.5, 7.2_
  - [x] 2.3 Create the Contact page
    - Add pre-addressed support, privacy, deletion, and copyright email actions.
    - Add credential/OTP safety warning.
    - _Requirements: 4.1–4.5_
  - [x] 2.4 Create the Delete Account page
    - Document in-app and post-uninstall request paths, minimum identifiers, verification, 30-day processing, deleted data, retained records, and local-data removal.
    - Add a pre-addressed request to `dhammapathai@gmail.com` without requesting passwords or OTPs.
    - _Requirements: 5.1–5.11, 9.2, 9.5_

- [x] 3. Configure safe static routing and headers
  - [x] 3.1 Add a branded static 404 page
    - Provide links back to Home, Privacy, Contact, and Delete Account.
    - _Requirements: 8.2_
  - [x] 3.2 Update only the Firebase public Hosting configuration
    - Remove the public catch-all SPA rewrite while preserving the Admin rewrite.
    - Add restrictive security/privacy headers compatible with static assets and `mailto:` actions.
    - _Requirements: 8.1–8.5_

- [x] 4. Validate listing readiness
  - [x] 4.1 Perform pre-deployment content and security validation
    - Check files, route links, unique metadata, responsive markup, placeholders, support address, and credential patterns.
    - Confirm Privacy/Data safety consistency and that no backend/Admin resource is in deployment scope.
    - _Requirements: 7.1–7.6, 8.5, 9.1–9.5_

- [x] 5. Deploy and verify the production public site
  - [x] 5.1 Deploy only `hosting:public` to explicit project `dhamma-path-prod`
    - Do not deploy Admin Hosting, Functions, Firestore, Storage, indexes, or other resources.
    - _Requirements: 8.3, 8.4_
  - [x] 5.2 Verify production HTTPS routes and record listing URLs
    - Verify Home, Privacy, Terms, Contact, Delete Account, and 404 behavior directly on production.
    - Record the Privacy and Account Deletion URLs in launch documentation.
    - _Requirements: 8.6, 9.1–9.6_