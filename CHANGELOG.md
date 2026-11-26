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

- Claude Code `.claude/settings.json` sets `BASH_MAX_OUTPUT_LENGTH` to `15000` and
  `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to `50` ([env vars](https://code.claude.com/docs/en/env-vars))
- **Breaking:** GitHub Models was retired on 2026-07-30, so the action now calls a configurable LLM provider: an OpenAI-compatible API via `API_BASE` + `AI_TOKEN`, or Anthropic via `ANTHROPIC_API_KEY` (default model `claude-sonnet-5-5`). It fails fast with a clear error if neither is set.
- `MODEL` and `AI_TOKEN` are now optional and have no GitHub Models defaults
- `test-action.yaml` takes free-text `api_base`/`model` inputs and reads the `AI_API_KEY`/`ANTHROPIC_API_KEY` secrets; `models: read` permission dropped
- Release flow moved to the `qte77/.github` reusables, pinned to the v0.1.2 tag commit (`@aeef158f…  # v0.1.2`) (#42):
  `bump-my-version.yaml` calls `bump-version` (signed bump commit, bump PR), the new `tag-release.yaml` tags `vX.Y.Z`,
  publishes the Release and moves the floating major tag once the bump PR is merged to `main`, and the new
  `publish-release.yaml` re-publishes a given tag on dispatch. Tag and Release are no longer created on the unmerged bump
  branch, and a failed run no longer deletes tags.

### Security

- Pinned every remaining `uses:` ref in `.github/workflows/*` and `action.yaml` to its commit SHA (`actions/checkout@v7`, `docker/login-action@v4`, `callowayproject/bump-my-version@1.8.1`, `github/codeql-action/{init,autobuild,analyze}@v4`), required by the org's new SHA-pinning Actions policy; this also fixes the resulting `CodeQL` workflow `startup_failure`. No version changes.

---

## [1.1.0] - 2026-03-23

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
