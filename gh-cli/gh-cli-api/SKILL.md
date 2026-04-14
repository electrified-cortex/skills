---
name: gh-cli-api
description: Make authenticated REST and GraphQL calls to the GitHub API via the CLI. Use when no dedicated gh subcommand covers the operation.
---

Use `gh api` only when domain skills unavailable.

REST — GET:
```
gh api /repos/owner/repo
gh api /user --jq '.login'
```

REST — mutate:
```
gh api --method POST /repos/owner/repo/issues \
  --field title="title" --field body="body"

gh api --method PATCH /repos/owner/repo/issues/123 \
  --field state="closed"
```

Pagination (multiple requests; slow on large datasets):
```
gh api /user/repos --paginate --jq '.[].name'
```

jq — simple extract:
```
gh api /repos/owner/repo --jq '.stargazers_count'
```

jq — filter + transform:
```
gh api /repos/owner/repo/issues --jq '[.[] | select(.state=="open") | {number, title}]'
```

GraphQL — query:
```
gh api graphql -f query='
  { viewer { login repositories(first: 5) { nodes { name } } } }'
```

GraphQL — mutation (resolve review thread):
```
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

GitHub Enterprise: add `--hostname enterprise.internal` to any call.

Token safety — never pass tokens as command arguments. Use env var:
```
GH_TOKEN=<token> gh api /user
```
