---
tool: google-workspace
kind: integration
covers_skills: [morning, mail-sweep]
---

# Google Workspace — Gmail, Drive, Sheets

> **skill-tool.** The `## Usages` below are proven, copy-paste-ready — the 80 % cases.
> Use them directly, no doc-reading, no prep.
> If your action isn't listed: read **## Reference**, derive it, run it — and **once it works,
> add a `### Usage`** (gotchas included) so next time falls into the instant path.
> Keep usages lean (≲10). If it overflows, drop the ones you haven't used in a while.

Account: `you@example.com`.

## Usages (proven — use directly)

### Usage: create a Gmail draft
Gotcha: needs `--params '{"userId":"me"}'`; body is a base64url RFC822 message in `--json`. No To/CC required.
stdout has a `Using keyring backend` preamble — strip non-JSON before parsing.
```bash
RAW=$(python3 -c 'import base64;print(base64.urlsafe_b64encode(b"Subject: <subject>\r\nContent-Type: text/plain; charset=\"UTF-8\"\r\n\r\n<body>\r\n").decode())')
gws gmail users drafts create --params '{"userId":"me"}' --json "{\"message\":{\"raw\":\"$RAW\"}}"   # add --dry-run to validate
# list:   gws gmail users drafts list   --params '{"userId":"me"}'
# delete: gws gmail users drafts delete --params '{"userId":"me","id":"<draft_id>"}'
```

### Usage: search Gmail + add a label
Gotcha: `addLabelIds`/`removeLabelIds` go in `--json` (request body), NOT `--params` — putting them in
`--params` stringifies the array → `Invalid label: [...]` (400).
```bash
gws gmail users labels list --params '{"userId":"me"}'                                    # list label ids
gws gmail users messages list --params '{"userId":"me","q":"from:<sender> subject:<subj>","maxResults":50}'
gws gmail users messages modify --params '{"userId":"me","id":"<msg_id>"}' --json '{"addLabelIds":["Label_xxx"]}'
```

## Reference (read only if no usage above fits)

### Gmail OAuth
- Read scope (`gmail.readonly`): token + client-secret under your OAuth config dir.
- Compose + Drive scopes (`gmail.compose`, `drive.file`): a separate token with the wider scopes.

### Drive
```bash
# upload a file to a target folder — folder id in <drive_folder_id>
gws drive files create --params '{"uploadType":"media"}' --json '{"name":"<file>","parents":["<drive_folder_id>"]}'
```

### Sheets — `gws` CLI
OAuth cache under your `gws` config dir.
```bash
gws sheets spreadsheets.values get        --params '{"spreadsheetId":"<id>","range":"<A1>"}'
gws sheets spreadsheets.values batchUpdate --params '{...}'
```

## Rules
- Sending mail / writing sheets is outward-facing → preview + Y/n confirm.
