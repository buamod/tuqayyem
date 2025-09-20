# Tasks: Mobile Rating App (Tuqayyem)

**Input**: Design documents from `/specs/001-mobile-app-to/`
**Prerequisites**: plan.md (required)

## Execution Flow (main)
```
1. Load plan.md from feature directory
2. Extract: tech stack, libraries, structure
3. Generate tasks by category
4. Apply task rules
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness
9. Return: SUCCESS (tasks ready for execution)
```

## Phase 3.1: Setup
- [x] T001 Create Flutter project "tuqyyem" in `src/`
- [~] T002 Setup repo for Trunk-Based Development (main branch, PR rules)
- [ ] T003 [P] Setup CI/CD pipeline with GitHub Actions (`.github/workflows/ci.yml`)
- [ ] T004 [P] Configure Firebase project for Android/iOS (`src/firebase/`)
- [ ] T005 [P] Apply code style (dart format, lint rules)

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
- [ ] T006 [P] Write widget tests for Landing page (`tests/widget/landing_test.dart`)
- [ ] T007 [P] Write widget tests for Dashboard (`tests/widget/dashboard_test.dart`)
- [ ] T008 [P] Write integration test for navigation (`tests/integration/navigation_test.dart`)

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T009 Build Landing page (modern, light theme, adaptive UI) in `src/pages/landing.dart`
- [ ] T010 Build Dashboard UI (list of cards for locations) in `src/pages/dashboard.dart`
- [ ] T011 Implement navigation from Landing to Dashboard (`src/app.dart`)

## Phase 3.4: MVP v2 Features
- [ ] T012 Add Signup/Sign-in page (`src/pages/auth.dart`)
- [ ] T013 Connect Firebase Auth (`src/services/auth_service.dart`)
- [ ] T014 Update Dashboard to pull sample locations from Firestore (`src/services/location_service.dart`)
- [ ] T015 Add tests for auth and data loading (`tests/integration/auth_data_test.dart`)

## Phase 3.5: General & Polish
- [ ] T016 Ensure every PR has tests and human review (repo settings)
- [ ] T017 UI design sign-off for buttons, colors, dashboard (review checklist)
- [ ] T018 [P] Update docs/README.md with setup and usage instructions

## Dependencies
- Setup (T001-T005) before tests (T006-T008)
- Tests (T006-T008) before implementation (T009-T011)
- MVP v2 (T012-T015) after MVP v1 (T009-T011)
- General/polish (T016-T018) after all features

## Parallel Example
```
# Launch T003, T004, T005 together:
Task: "Setup CI/CD pipeline with GitHub Actions"
Task: "Configure Firebase project for Android/iOS"
Task: "Apply code style (dart format, lint rules)"

# Launch T006-T008 together:
Task: "Write widget tests for Landing page"
Task: "Write widget tests for Dashboard"
Task: "Write integration test for navigation"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- UI sign-off required before release
- Avoid: vague tasks, same file conflicts

## Validation Checklist
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
