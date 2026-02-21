#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys

data = sys.stdin.read()

# Matches:
#   vault://secret/foo/bar#baz
#   vault://secret/foo/bar
pat = re.compile(
    r"vault://([A-Za-z0-9_.-]+/[A-Za-z0-9_./:-]+)(?:#([A-Za-z0-9_.-]+))?"
)

cache = {}
stats = {
    "placeholders_found": 0,
    "replacements_done": 0,
    "cache_hits": 0,
}
DEBUG = os.getenv("VAULT_INJECT_DEBUG", "").lower() in {"1", "true", "yes", "on"}
DEBUG_SHOW_VALUES = os.getenv("VAULT_INJECT_DEBUG_SHOW_VALUES", "").lower() in {
    "1",
    "true",
    "yes",
    "on",
}


def log(msg):
    if DEBUG:
        sys.stderr.write(f"[vault-inject] {msg}\n")


def vault_kv_get_field(path, field):
    key = (path, field)
    if key in cache:
        stats["cache_hits"] += 1
        log(f"cache hit for {path}#{field}")
        return cache[key]

    r = subprocess.run(
        ["vault", "kv", "get", f"-field={field}", path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=os.environ.copy(),
    )
    if r.returncode != 0:
        sys.stderr.write(f"ERROR: vault kv get failed for {path}#{field}\n{r.stderr}\n")
        sys.exit(r.returncode)

    cache[key] = r.stdout.rstrip("\n")
    if DEBUG_SHOW_VALUES:
        log(f"resolved {path}#{field} -> {cache[key]!r}")
    else:
        log(f"resolved {path}#{field} -> <redacted>")
    return cache[key]


def vault_kv_get_all(path):
    key = (path, None)
    if key in cache:
        stats["cache_hits"] += 1
        log(f"cache hit for {path}")
        return cache[key]

    r = subprocess.run(
        ["vault", "kv", "get", "-format=json", path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=os.environ.copy(),
    )
    if r.returncode != 0:
        sys.stderr.write(f"ERROR: vault kv get failed for {path}\n{r.stderr}\n")
        sys.exit(r.returncode)

    payload = json.loads(r.stdout)
    secret_data = payload["data"]["data"]

    # Render as YAML-ish block (2-space indent friendly)
    rendered = "\n".join(
        f"{k}: {json.dumps(v) if isinstance(v, str) else v}"
        for k, v in secret_data.items()
    )

    cache[key] = rendered
    if DEBUG_SHOW_VALUES:
        log(f"resolved {path} -> {rendered!r}")
    else:
        log(f"resolved {path} -> <redacted>")
    return rendered


def repl(match):
    stats["placeholders_found"] += 1
    path = match.group(1)
    field = match.group(2)
    log(f"found placeholder vault://{path}{('#' + field) if field else ''}")

    if field:
        result = vault_kv_get_field(path, field)
    else:
        result = vault_kv_get_all(path)

    stats["replacements_done"] += 1
    return result


output = pat.sub(repl, data)

if DEBUG:
    log(f"summary {json.dumps(stats)}")

sys.stdout.write(output)
