# gha-ai-changelog

Summarize PR commits into changelog entries using an OpenAI-compatible or Anthropic LLM API.

> **Breaking (2026-07-30):** GitHub Models has been retired, so the action no longer has a
> default backend. Set `API_BASE` + `AI_TOKEN` (OpenAI-compatible) or `ANTHROPIC_API_KEY`.

![Version](https://img.shields.io/badge/version-1.1.0-8A2BE2)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Test Action](https://github.com/qte77/gha-ai-changelog/actions/workflows/test-action.yaml/badge.svg)
![CodeFactor](https://www.codefactor.io/repository/github/qte77/gha-ai-changelog/badge)
![CodeQL](https://github.com/qte77/gha-ai-changelog/actions/workflows/codeql.yaml/badge.svg)
![Dependabot](https://img.shields.io/badge/dependabot-enabled-025e8c)

For version history have a look at the [CHANGELOG](CHANGELOG.md).

## Usage

```yaml
- uses: qte77/gha-ai-changelog@v1
  with:
    PR_NUMBER: ${{ github.event.pull_request.number }}
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    # or an OpenAI-compatible provider:
    # API_BASE: https://api.openai.com/v1
    # MODEL: gpt-4.1
    # AI_TOKEN: ${{ secrets.OPENAI_API_KEY }}
```

Add a placeholder comment in your changelog file where the AI summary should be inserted:

```markdown
<!-- INSERT_CHANGELOG_SUMMARY_HERE -->
```

The summary is inserted **after** the placeholder line. The placeholder is preserved for reruns.

## What it does

1. Checks out the repository and creates a new branch.
2. Fetches commit messages from the specified pull request via the GitHub API.
3. Sends the commit messages to the configured LLM provider to generate a changelog summary.
4. Inserts the AI-generated summary into the changelog file after the placeholder comment.
5. Commits and pushes the updated changelog to the new branch.
6. Optionally creates a pull request with the changes (when `CREATE_PR` is `true`).
7. Cleans up the branch, PR, and tag on failure or cancellation.

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `PR_NUMBER` | Yes | — | Pull request number to generate changelog for |
| `API_BASE` | No | — | OpenAI-compatible API base URL; takes precedence over `ANTHROPIC_API_KEY` |
| `ANTHROPIC_API_KEY` | No | — | Anthropic API key; used when `API_BASE` is empty |
| `MODEL` | No | `claude-sonnet-5-5` (Anthropic) | Model ID; required with `API_BASE` |
| `OUT_FILE` | Yes | `CHANGELOG.md` | The file to update with the changelog summary |
| `GH_TOKEN` | Yes | `${{ github.token }}` | GitHub token for fetching PR commits |
| `AI_TOKEN` | No | — | Bearer token for the API at `API_BASE` |
| `COMMITTER_NAME` | Yes | `AIChangelog-GHA` | Name of the committer for the changelog commit |
| `COMMITTER_EMAIL` | Yes | `ai-changelog@gha` | Email of the committer for the changelog commit |
| `PLACEHOLDER` | Yes | `<!-- INSERT_CHANGELOG_SUMMARY_HERE -->` | Placeholder comment in OUT_FILE to insert summary after |
| `CREATE_PR` | No | `false` | Whether to create a pull request with the changes |

## Outputs

This action has no outputs.

## Permissions required

```yaml
permissions:
  contents: write       # commit and push changelog
  pull-requests: write  # create PR (if CREATE_PR is 'true')
```

## License

[Apache-2.0](LICENSE)
