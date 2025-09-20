Tuqayyem Constitution
Core Principles
I. Specifications are the single source of truth
Every feature, change, and implementation MUST be derived from an approved specification. No code, test, or documentation may contradict the specification. All contributors are responsible for ensuring alignment.

II. Code must be human-readable and maintainable
All code MUST be clear, well-documented, and easy for any team member to understand and modify. Complex logic MUST be justified in comments. Readability and maintainability take precedence over cleverness or brevity.

III. Every feature requires automated tests
No feature may be merged without passing automated tests. This includes unit and widget tests for all new functionality. Test coverage MUST be sufficient to validate all acceptance criteria in the specification.

IV. AI tools assist but never override the spec
AI-generated code, suggestions, or documentation MUST strictly follow the specification. Human review is required for all AI contributions. AI may not introduce changes that conflict with the approved spec.

V. Collaboration based on clarity, respect, and transparency
All project communication and review processes MUST be conducted with clarity, respect, and transparency. Disagreements are resolved through open discussion and reference to the specification.

Development Guidelines
Flutter is the required framework for cross-platform mobile development.
Trunk-Based Development branching model MUST be used.
Each feature MUST include both unit and widget tests.
All pushes MUST go through PR review.
UI elements MUST be signed off by a human reviewer.
Collaboration & AI Usage
Human input is REQUIRED for all design validation.
AI-generated code MUST align with the specification and pass all tests.
Platform-specific UI MUST use Material (Android) and Cupertino (iOS) components, maintaining consistency across platforms.
Governance
This constitution supersedes all other project practices and guidelines.
Amendments require documentation, team approval, and a migration plan if breaking changes are introduced.
All PRs and reviews MUST verify compliance with the constitution and specification.
Constitution versioning follows semantic rules:
MAJOR: Backward incompatible governance/principle removals or redefinitions.
MINOR: New principle/section added or materially expanded guidance.
PATCH: Clarifications, wording, typo fixes, non-semantic refinements.
Compliance reviews are conducted at each release and before major merges.
TODO(RATIFICATION_DATE): Original adoption date required.
Version: 2.2.0 | Ratified: TODO(RATIFICATION_DATE) | Last Amended: 2025-09-20

Summary:

New version: 2.2.0 (MINOR bump: new principles and expanded guidance).
Manual follow-up: Add original ratification date, update README.md, and review commands templates if/when directory is created.
Suggested commit message:
docs: amend constitution to v2.2.0 (principle additions + governance update)