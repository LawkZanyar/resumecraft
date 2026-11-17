# Phase 1 report: Frontend Application (`v0.1.0-frontend`)

## Delivered

| Task | Member | Delivered |
|---|---|---|
| 1.1 | Lawk Zaniar | Project setup, theme (light and dark), five-tab navigation, shared `Result`/`Failure`, validators and widgets, shared entities and repository contracts, fake sign-in, splash, onboarding, login, registration, password reset, Home dashboard, Profile, settings, notification settings, locked vault entry, and the shared resume data everyone reads: sample resumes, fake resume repository and resume providers |
| 1.2 | Pasha Mariwan | My Resumes list, 8-step editor for every section, three templates (Classic, Modern, Minimal), template gallery, live preview, customization panel |
| 1.3 | Hananeh Mohsen | `AiService` contract, offline sample AI engine (`FakeAiService`), AI widgets, Career Assistant hub, improve resume, analysis, skill suggestions, voice-to-resume with review, interview setup, questions, feedback and report |
| 1.4 | Fatemeh Kamal | 18 labeled sample jobs at fictional companies, sample applications, fake job and application repositories, Jobs hub, search and filters, job details, saved jobs, nearby layout with radius control, tracker by status, application details, statistics |

## Labels still in place (by design)

- "Available in Phase 2": PDF export, save AI score, AI consent, account deletion, resume completion and score on Home.
- "Available in Phase 3": camera scanning, microphone recording, GPS, interactive map, biometric vault.
- "Available in Phase 4": job compatibility, reminders, AI follow-up messages.
- All sample content shows a "Sample" or "Sample AI result" label.

## Tests

`flutter analyze`: no issues. `flutter test`: all tests pass (validators, result type, fake repositories,
auth flow, every tab reachable, resume editor validation, templates, AI engine, interview flow, job search, tracker).

## Known issues

- Runs on fakes only; nothing is persisted between app restarts in this phase.
