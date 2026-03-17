# gha-ai-changelog

Summarize PR commits into changelog entries using GitHub Models AI API.

![Version](https://img.shields.io/badge/version-1.0.0-8A2BE2)
[![test-action](https://github.com/qte77/gha-ai-changelog/actions/workflows/test-action.yaml/badge.svg)](https://github.com/qte77/gha-ai-changelog/actions/workflows/test-action.yaml)
[![CodeQL](https://github.com/qte77/gha-ai-changelog/actions/workflows/codeql.yaml/badge.svg)](https://github.com/qte77/gha-ai-changelog/actions/workflows/codeql.yaml)
[![vscode.dev](https://img.shields.io/static/v1?logo=visualstudiocode&label=&message=vscode.dev&labelColor=2c2c32&color=007acc&logoColor=007acc)](https://vscode.dev/github/qte77/gha-ai-changelog)

For version history have a look at the [CHANGELOG](CHANGELOG.md).

## Usage

```yaml
- uses: qte77/gha-ai-changelog@v1
  with:
    PR_NUMBER: ${{ github.event.pull_request.number }}
    AI_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Add a placeholder comment in your changelog file where the AI summary should be inserted:

```markdown
<!-- INSERT_CHANGELOG_SUMMARY_HERE -->
```

The summary is inserted **after** the placeholder line. The placeholder is preserved for reruns.

## Inputs

| Name | Description | Default | Required |
| --- | --- | --- | --- |
| `PR_NUMBER` | Pull request number to generate changelog for | — | Yes |
| `MODEL` | GitHub Models AI model to use | `openai/gpt-4.1` | Yes |
| `OUT_FILE` | The file to update with the changelog summary | `CHANGELOG.md` | Yes |
| `GH_TOKEN` | GitHub token for fetching PR commits | `${{ github.token }}` | Yes |
| `AI_TOKEN` | Token for GitHub Models AI API | `${{ github.token }}` | Yes |
| `COMMITTER_NAME` | Name of the committer for the changelog commit | `AIChangelog-GHA` | Yes |
| `COMMITTER_EMAIL` | Email of the committer for the changelog commit | `ai-changelog@gha` | Yes |
| `PLACEHOLDER` | Placeholder comment in OUT_FILE to insert summary after | `<!-- INSERT_CHANGELOG_SUMMARY_HERE -->` | Yes |
| `CREATE_PR` | Whether to create a pull request with the changes | `false` | No |

## Permissions required

```yaml
permissions:
  contents: write       # commit and push changelog
  pull-requests: write  # create PR (if CREATE_PR is 'true')
  models: read          # call GitHub Models AI API
```
