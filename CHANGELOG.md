# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), i.e. MAJOR.MINOR.PATCH (Breaking.Feature.Patch).

Types of changes:

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## [Unreleased]

### Changed

- `callowayproject/bump-my-version` `@0.29.0` → `@1.2.7`
- `actions/checkout` `@v4` → `@v6` in `action.yaml`
- Bump workflow creates GitHub Release and updates floating major tag
- Cleanup script includes release deletion

### Removed

- Orphaned `summarize-jobs-reusable.yaml`

---

## [1.0.0] - 2026-03-17

### Added

- Composite action `action.yaml` with 9 inputs and branding for GitHub Marketplace
- BSD-3-Clause license (`LICENSE.md`)
- Cleanup script for failed runs (`.github/scripts/delete_branch_pr_tag.sh`)
- Bumpversion config in `pyproject.toml`
- Conventional commits template (`.gitmessage`)
- Self-test workflow `test-action.yaml` (replaces inline `generate-changelog-ai.yaml`)
- Bumpversion workflow `bump-my-version.yaml`
- Reusable job summary workflow `summarize-jobs-reusable.yaml`
- README with usage, inputs table, and permissions

### Fixed

- B1: `outputs.summary` case mismatch — use uppercase `SUMMARY`
- B2: `{{ env.PR_NUMBER }}` missing `$` — use `${{ inputs.PR_NUMBER }}`
- B3: `OUT_FILE` empty on PR trigger — inputs have defaults
- B4: `MODEL` empty on PR trigger — inputs have defaults
- B5: `PR_COMMITS` empty-check misses errors — validate with `jq -e '.[0].sha'`
- B6: Multi-line commits corrupt output — use `EOFCOMMITS` heredoc delimiter
- B7: Unescaped JSON payload — use `jq -n --arg` for safe construction
- B8: `git push` detached HEAD — push to named `BRANCH_NEW`
- B9: `test-action.yaml` missing checkout before `uses: ./` — action.yaml not found

### Changed

- Removed `languages: python` from CodeQL workflow (no Python source)
- Replaced inline workflow with `uses: ./` self-test pattern
- Removed `pip` ecosystem from dependabot (no Python dependencies)

<!-- INSERT_CHANGELOG_SUMMARY_HERE -->

---
