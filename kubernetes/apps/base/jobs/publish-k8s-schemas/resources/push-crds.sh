#!/usr/bin/env bash
set -eu
export HOME=/tmp
git clone --depth=1 \
    "https://x-access-token:${GIT_TOKEN}@${GIT_REPO}" \
    /tmp/repo
mkdir -p /tmp/repo/schemas
cp -r /data/crdSchemas/. /tmp/repo/schemas/
cd /tmp/repo
git add .
if git diff --cached --quiet; then
    echo "No changes to commit"
    exit 0
fi
git commit -m "chore: update CRD schemas ($(date -u '+%Y-%m-%dT%H:%M:%SZ'))"
git push
