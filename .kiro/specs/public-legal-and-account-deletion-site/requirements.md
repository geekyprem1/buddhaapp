# Requirements Document

## Introduction

This specification defines the production public website for Dhamma Path. The site will provide stable Google Play listing URLs, explain the app and its data practices accurately, and provide a usable account-deletion request path outside the installed app. It replaces the current Firebase Hosting placeholder at the `public` target.

The initial release is an English, mobile-first static website. Legal copy is an operational disclosure derived from implemented behavior and should receive owner/legal review before store submission.

## Scope

The release includes these canonical public routes:

- `/` — app overview and links to all public documents
- `/privacy` — Privacy Policy
- `/terms` — Terms and Conditions
- `/contact` — support and legal contact information
- `/delete-account` — account and associated-data deletion instructions/request path

The site will be deployed only to the production Firebase Hosting `public` target for `dhamma-path-prod`. Admin Hosting, Functions, Firestore, Storage, indexes, users, and project data are outside this deployment.

## Glossary

- **Public Site**: Static content served by Firebase Hosting target `public`.
- **App**: The Dhamma Path Android mobile application (`app.dhammapath`).
- **Account Data**: Firebase Auth identity plus the app user profile, preferences, alarms, tokens, and user-owned Storage files.
- **Deletion Request**: A verified request to remove an account and associated deletable data.
- **Retention Record**: Minimal deletion proof, audit, fraud-prevention, support, or legally required record retained after account deletion.
- **Owner**: The person or organization publishing Dhamma Path on Google Play.

## Requirements

### Requirement 1: Public routes and navigation

**User Story:** As a prospective or existing user, I want stable public pages so that I can understand the app and its policies without installing or signing into it.

#### Acceptance Criteria

1. THE Public Site SHALL serve distinct content at `/`, `/privacy`, `/terms`, `/contact`, and `/delete-account`.
2. WHEN a user opens any public route directly, THE Public Site SHALL return a successful page without depending on client-side authentication.
3. THE Public Site SHALL provide visible navigation links to Privacy, Terms, Contact, and Delete Account from every page.
4. THE Public Site SHALL identify the product as “Dhamma Path” and describe its Buddhist wallpapers, audio, meditation, chanting, calendar, daily prayer, and status features without advertising unshipped supporter-ID functionality.
5. THE Public Site SHALL avoid links to the private Admin panel.


### Requirement 2: Accurate Privacy Policy

**User Story:** As a user, I want a clear privacy disclosure so that I understand what data is handled and why.

#### Acceptance Criteria

1. THE Privacy Policy SHALL identify the Owner, App name, effective date, and a verified privacy/support contact.
2. THE Privacy Policy SHALL disclose mandatory account authentication through phone OTP or Google Sign-In.
3. THE Privacy Policy SHALL describe collected account/profile data, including UID, name, phone or email, optional profile URL, language, selected teachers, onboarding state, notification preferences/tokens, platform, and activity timestamps.
4. THE Privacy Policy SHALL describe alarms, contact messages, app preferences, local caches, and engagement/diagnostic events according to implemented behavior.
5. THE Privacy Policy SHALL explain the purposes for authentication, personalization, content delivery, reminders, notifications, support, security, reliability, and service improvement.
6. THE Privacy Policy SHALL identify Google/Firebase services used for authentication, database, storage, functions, messaging, analytics, remote configuration, and abuse protection without claiming inactive services are active.
7. THE Privacy Policy SHALL state that selected status-personalization photos remain on-device under the current implementation, while separately disclosing any profile image URL or user-owned Storage files.
8. THE Privacy Policy SHALL disclose relevant Android permissions in plain language, including notifications, camera, wallpaper, ringtone/system settings, storage/media, alarms, boot rescheduling, wake lock, and foreground playback.
9. THE Privacy Policy SHALL explain data retention, security controls, user choices, deletion rights, policy updates, and cross-links to Contact and Delete Account.
10. THE Privacy Policy SHALL not claim that Firebase Web API keys, UI hiding, or client code are security boundaries; authentication and Firebase rules SHALL be represented accurately.

### Requirement 3: Terms and Conditions

**User Story:** As a user, I want understandable usage terms so that I know the permitted use and service limitations.

#### Acceptance Criteria

1. THE Terms page SHALL identify Dhamma Path, its effective date, acceptance mechanism, and contact path.
2. THE Terms page SHALL cover account responsibility, lawful/respectful use, prohibited misuse, intellectual-property and licensed-content limits, personal-use downloads, and user-submitted information.
3. THE Terms page SHALL explain that availability, online content, notifications, alarms, device integrations, and third-party services can vary by device, permissions, connectivity, and platform behavior.
4. THE Terms page SHALL include reasonable warranty, liability, suspension, termination, and change-of-service language without inventing an unverified legal entity, address, or jurisdiction.
5. THE Terms page SHALL link to the Privacy Policy, Contact page, and Delete Account page.

### Requirement 4: Public contact channel

**User Story:** As a user or store reviewer, I want a functional contact channel so that privacy, support, copyright, and deletion questions can reach the Owner.

#### Acceptance Criteria

1. THE Contact page SHALL display the Owner-confirmed public support email `dhammapathai@gmail.com` before production deployment.
2. THE Contact page SHALL provide explicit categories for general support, privacy/data requests, account deletion, and copyright/licensing concerns.
3. THE Contact page SHALL warn users never to send passwords, OTP codes, private keys, service-account files, or payment credentials.
4. THE Public Site SHALL not expose Admin login addresses or personal administrator credentials as support contacts.
5. IF a public support email has not been verified, THEN production deployment SHALL be considered blocked rather than publishing a fabricated address.

### Requirement 5: Account-deletion web resource

**User Story:** As an account holder who may no longer have the App installed, I want a public deletion-request path so that I can request deletion of my account and associated data.

#### Acceptance Criteria

1. THE Delete Account page SHALL clearly identify Dhamma Path and explain both the in-app path (`Profile → Delete Account`) and a functional web-accessible request method.
2. THE web-accessible method SHALL remain usable without installing or signing into the App.
3. THE request instructions SHALL ask only for the minimum account identifier and verification information needed to locate and authenticate the requester.
4. THE request instructions SHALL explicitly state that passwords and OTP codes must never be submitted.
5. THE page SHALL state that verified requests are processed within 30 days and SHALL not promise immediate deletion.

6. THE page SHALL distinguish data normally deleted—Firebase Auth account, user profile, alarms, notification tokens, and files under the user-owned Storage path—from data that may be retained.
7. THE page SHALL disclose that minimal deletion proof, security/audit records, legally required records, and support correspondence may be retained for stated purposes and limited periods.
8. WHEN the Owner receives a web request, THE Owner SHALL verify account ownership without requesting a password or OTP before executing deletion.
9. THE published workflow SHALL match the implemented admin-reviewed deletion queue and SHALL not imply an automatic instant erase.
10. THE page SHALL explain that uninstalling the App or clearing device storage removes local app data, while server-side deletion requires a deletion request.
11. IF no verified web-accessible request channel exists, THEN the page SHALL not be represented as Play account-deletion compliant and production deployment SHALL be blocked.

### Requirement 6: Accessibility and responsive presentation

**User Story:** As a user on any common device or with accessibility needs, I want readable policy pages that work without special software.

#### Acceptance Criteria

1. THE Public Site SHALL be usable at viewport widths from 320 pixels through desktop layouts without horizontal scrolling.
2. THE Public Site SHALL use semantic headings, landmarks, lists, links, and keyboard-visible focus states.
3. THE Public Site SHALL meet WCAG AA contrast intent and respect reduced-motion preferences.
4. THE Public Site SHALL not require JavaScript for core legal content or navigation.
5. THE Public Site SHALL provide descriptive page titles, descriptions, language metadata, and a clear “Last updated” date.
6. THE Public Site SHALL avoid auto-playing media, tracking pixels, cookie banners without cookies, and unnecessary third-party scripts.

### Requirement 7: Content integrity and owner-controlled values

**User Story:** As the Owner, I want publication gates so that the site does not make false legal or operational claims.

#### Acceptance Criteria

1. THE site source SHALL keep the verified support email, Owner identity, and effective date easy to locate and update.
2. THE production release SHALL not use placeholder company names, postal addresses, jurisdictions, response times, or support contacts.
3. THE policy copy SHALL reflect that App Check enforcement may vary by platform/environment and SHALL not make it the sole data-access control claim.
4. THE policy copy SHALL not claim active Crashlytics collection while Crashlytics remains removed from the Android dependency set.
5. WHEN implemented data handling materially changes, THE Owner SHALL update the relevant public page and its “Last updated” date before or with the app release.
6. THE site SHALL state that it does not sell personal data only if that remains true at deployment review; ads and unrelated marketing trackers are out of scope for this release.

### Requirement 8: Hosting and safe deployment

**User Story:** As the release owner, I want an isolated public-site deployment so that legal-page publication cannot modify the Admin or backend.

#### Acceptance Criteria

1. THE source SHALL remain under `firebase/public_site` and SHALL be deployable without an application build pipeline.
2. THE Hosting configuration SHALL serve each canonical route with the intended content and SHALL provide a branded not-found experience for unsupported paths.
3. THE production deployment command SHALL explicitly target only `hosting:public` and project `dhamma-path-prod`.
4. THE deployment SHALL NOT include `hosting:admin`, Functions, Firestore rules/indexes, Storage rules, or other Firebase resources.
5. BEFORE deployment, THE release process SHALL verify that no API keys, service-account material, passwords, OTPs, or private credentials were added to public-site files.
6. AFTER deployment, THE release process SHALL verify HTTPS and successful direct access to all five canonical routes on the production public Hosting domain.

### Requirement 9: Google Play listing readiness

**User Story:** As the Play Console publisher, I want stable compliant URLs so that I can complete the store listing and data-safety declarations.

#### Acceptance Criteria

1. THE Privacy Policy URL SHALL be a publicly accessible HTTPS URL that does not require authentication.
2. THE Account Deletion URL SHALL point directly to `/delete-account`, not only to the homepage or Privacy Policy.
3. THE pages SHALL be readable without downloading files and SHALL not be blocked from normal store-review access.
4. THE Privacy Policy and deletion disclosures SHALL be reconciled with the Play Data safety form before submission.
5. THE site SHALL visibly identify Dhamma Path on the Privacy and Delete Account pages.
6. THE production URLs and verification results SHALL be recorded in project launch documentation after deployment.

## Out of Scope

- Legal advice or certification of compliance
- Public user authentication or a new anonymous Firebase deletion API
- Changes to account-deletion Functions, Firestore/Storage rules, or Admin workflows
- Custom-domain/DNS setup
- Supporter-ID verification
- Advertising, marketing analytics, cookies, or newsletter collection
- Full Hindi/Marathi legal translations in the initial release

## Release Blockers

The Public Site SHALL NOT be deployed as listing-ready until the Owner supplies and verifies a public support/privacy email and confirms the publisher identity displayed in the policies. A static page that only instructs users to reinstall the App is insufficient; the verified support channel must accept deletion requests from users who no longer have the App.