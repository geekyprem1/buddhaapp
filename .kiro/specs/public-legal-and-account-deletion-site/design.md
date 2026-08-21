# Design Document

## Overview

Dhamma Path’s public legal site will be a dependency-free, multi-page static website served by the existing Firebase Hosting `public` target. It will replace the placeholder landing page and expose stable HTTPS pages suitable for Google Play’s Privacy Policy and Account Deletion URL fields.

The design intentionally avoids Flutter Web, a JavaScript router, Firebase client SDKs, cookies, analytics, and form backends. Account-deletion requests will use the Owner-confirmed mailbox `dhammapathai@gmail.com` through a pre-addressed email action, allowing requests after app uninstall without adding anonymous database writes.

## Goals

- Accurate disclosures based on implemented mobile and backend behavior
- Direct, durable Play listing URLs
- Functional support and deletion request actions
- Fast, accessible pages on low-bandwidth mobile devices
- Isolated production deployment of `hosting:public` only

## Non-Goals

- Legal certification
- Admin panel or mobile app changes
- Backend deletion automation
- Custom-domain setup
- Public authentication or anonymous Firestore writes
- Hindi/Marathi legal translations in this release

## File Structure

```text
firebase/public_site/
├── index.html
├── privacy/index.html
├── terms/index.html
├── contact/index.html
├── delete-account/index.html
├── 404.html
└── assets/
    └── site.css
```

Each route is a real directory-backed HTML document. Core content and navigation work with JavaScript disabled.

## Routing and Hosting

The `public` Hosting target will continue to serve `firebase/public_site`. Its catch-all rewrite to the landing page will be removed so Firebase Hosting can resolve directory indexes and `404.html` normally. The `admin` target and its SPA rewrite remain unchanged.

Canonical production URLs:

- `https://dhamma-path-prod-public.web.app/`
- `https://dhamma-path-prod-public.web.app/privacy/`
- `https://dhamma-path-prod-public.web.app/terms/`
- `https://dhamma-path-prod-public.web.app/contact/`
- `https://dhamma-path-prod-public.web.app/delete-account/`

Firebase Hosting headers will add a restrictive content security policy, `X-Content-Type-Options`, `Referrer-Policy`, and a limited `Permissions-Policy`. No header may interfere with `mailto:` links or normal static asset loading.


## Architecture

The site uses Firebase Hosting as a static origin. Requests resolve to directory-backed HTML documents and one shared CSS asset; there is no application runtime, API, database client, or authentication layer. The production `public` target is isolated from the Flutter Admin SPA target.

```text
Browser → Firebase Hosting (public target)
        ├── /index.html
        ├── /privacy/index.html
        ├── /terms/index.html
        ├── /contact/index.html
        ├── /delete-account/index.html
        ├── /404.html
        └── /assets/site.css
```

## Components and Interfaces

- **Page shell:** semantic header, navigation, main landmark, and footer repeated in each HTML document.
- **Legal content pages:** static, route-specific HTML with unique metadata and cross-links.
- **Shared stylesheet:** responsive tokens, typography, cards, navigation, focus, print, and reduced-motion rules.
- **Email interface:** explicit `mailto:dhammapathai@gmail.com` actions with category-specific subjects; no credentials or OTPs requested.
- **Hosting interface:** Firebase `public` target serves static files and applies security/privacy headers.
- **Release interface:** explicit `firebase deploy --only hosting:public --project dhamma-path-prod` command.

## Data Models

No runtime data model or client-side persistence exists. Policy content is represented as versioned HTML. The only structured values embedded in pages are:

| Value | Representation |
|---|---|
| Product name | `Dhamma Path` text |
| Support contact | `dhammapathai@gmail.com` mailto URI |
| Effective/update date | Human-readable `<time datetime="YYYY-MM-DD">` |
| Canonical route | Absolute production HTTPS `<link rel="canonical">` |
| Deletion request | Pre-addressed email subject/body containing user-supplied account identifier |

## Correctness Properties

### Property 1: Distinct route resolution
Every primary navigation target resolves to a distinct document with route-specific title and content.

**Validates: Requirements 1.1, 1.2, 8.2**

### Property 2: Consistent public identity
Every page displays the same Dhamma Path identity and `dhammapathai@gmail.com` support contact.

**Validates: Requirements 1.4, 2.1, 4.1, 9.5**

### Property 3: Safe deletion instructions
Privacy and deletion pages never request a password, OTP, private key, or service-account material.

**Validates: Requirements 4.3, 5.4**

### Property 4: Hosting isolation
The public Hosting configuration change leaves the Admin target and its SPA rewrite unchanged.

**Validates: Requirements 8.1, 8.4**

### Property 5: Deployment isolation
The production deploy command targets only `hosting:public` in `dhamma-path-prod`.

**Validates: Requirements 8.3, 8.4**

### Property 6: Credential-free source
Public-site source contains no Firebase client configuration or private credential.

**Validates: Requirements 8.5**

## Error Handling

- Unknown routes return the branded `404.html` with recovery links.
- If an email client is unavailable, the visible mailbox remains copyable.
- If mailbox verification or publisher review fails, deployment stops rather than substituting placeholder contact details.
- If any production route returns the wrong page or non-success status, verification fails and the release is not declared listing-ready.
- If deployment output includes a non-public target, stop and investigate before any retry.

## Testing Strategy

No new automated test suite is required for the dependency-free pages. Validation will use targeted static checks: file existence, internal-link resolution, unique title/canonical metadata, placeholder and credential scans, HTML diagnostics where available, Firebase configuration review, and post-deployment HTTPS smoke checks for all routes plus 404 behavior.

## Visual System

The site will reuse the existing Dhamma Path visual direction: warm ivory background, maroon primary color, restrained gold accent, rounded content panels, and readable system fonts. Layout uses a narrow prose column for legal pages and larger feature cards on the homepage.

Shared page anatomy:

1. Skip-to-content link
2. Branded header and primary navigation
3. Page title, summary, and last-updated date
4. Semantic main content with short sections and lists
5. Call-to-action panel where relevant
6. Footer with legal navigation and support email

Focus indicators, link underlines, generous line height, and reduced-motion support are mandatory. No remote fonts or images are needed.

## Page Design

### Home

Introduces Dhamma Path, summarizes shipped feature groups, and directs users to Privacy, Terms, Contact, and Delete Account. It contains no Admin link and makes no claim about supporter-ID functionality.

### Privacy

Sections cover information supplied by users, automatically processed technical/service data, device permissions, local-only status photos, processing purposes, Firebase/Google providers, retention, security, user controls, deletion, children/audience statement limited to confirmed facts, policy changes, and contact.

The page will not claim Crashlytics is active while the Android package does not include it. It may describe diagnostic/error information generically only where current error reporting actually transmits it.

### Terms

Sections cover acceptance, eligibility/account responsibility, permitted personal use, respectful/prohibited conduct, content ownership and licensing, device permissions and integrations, availability, third-party services, disclaimers, limitation of liability, suspension, changes, and contact. It will not invent a registered company, postal address, or governing jurisdiction.

### Contact

Displays `dhammapathai@gmail.com` and pre-addressed email actions for general support, privacy, account deletion, and copyright/licensing. It warns users not to send passwords, OTPs, private keys, service-account files, or payment credentials.

### Delete Account

Explains:

- In-app path: Profile → Delete Account
- External path: pre-addressed email to `dhammapathai@gmail.com`
- Minimum request data: account phone number or email and a request to delete
- No password or OTP collection
- Ownership verification through a safe follow-up
- Processing within 30 days after verification
- Normally deleted server data
- Limited deletion proof, audit/security records, and support correspondence that may be retained
- Local data removal through uninstalling or clearing app storage

Suggested deletion email subject: `Dhamma Path Account Deletion Request`. The body template asks for the account email or phone number and optional context only.

## Security and Privacy

- No Firebase SDK or API key is included in the public site.
- No forms write anonymously to Firestore or Functions.
- No cookies, local storage, analytics, fingerprinting, or third-party embeds are used.
- External communication uses explicit `mailto:` links initiated by the user.
- All dynamic-looking content is plain escaped HTML.
- Public pages expose only the confirmed support mailbox, never Admin credentials.

## Deployment Design

Validation occurs before deployment:

1. Confirm all expected files and internal links.
2. Scan public-site source for credential patterns and placeholders.
3. Confirm `firebase.json` changes affect only the `public` target.
4. Deploy with `firebase deploy --only hosting:public --project dhamma-path-prod`.
5. Fetch every canonical HTTPS URL and verify route-specific title/content.
6. Record final Privacy and Delete Account URLs in launch documentation.

Admin Hosting will continue to deploy through GitHub automation only when its own source paths change. This public-site release is a targeted manual deployment and must not deploy backend resources.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Policy copy diverges from app behavior | Base copy on inspected source and require update when behavior changes |
| Deletion requests cannot be submitted after uninstall | Public pre-addressed email action |
| Spam or impersonated deletion requests | Verify ownership before Admin executes deletion |
| Accidental backend/Admin deployment | Explicit `hosting:public` and project flags |
| Catch-all serves wrong policy page | Real directory indexes and removal of public catch-all rewrite |
| Legal overclaim | Avoid unverified entity, jurisdiction, SLA, or inactive-service claims |

## Acceptance Verification

A release is complete when all five production URLs load over HTTPS, each has a unique title and intended content, navigation works at mobile/desktop sizes, email links target the confirmed mailbox, unsupported routes show the custom 404 page, and Firebase deployment output confirms only the production public Hosting site changed.