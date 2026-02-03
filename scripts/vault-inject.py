#!/usr/bin/env python3
import os, re, subprocess, sys, json

data = sys.stdin.read()

# Matches:
#   vault://secret/foo/bar#baz
#   vault://secret/foo/bar
pat = re.compile(
    r'vault://([A-Za-z0-9_.-]+/[A-Za-z0-9_./:-]+)(?:#([A-Za-z0-9_.-]+))?'
)

cache = {}

def vault_kv_get_field(path, field):
    key = (path, field)
    if key in cache:
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
    return cache[key]


def vault_kv_get_all(path):
    key = (path, None)
    if key in cache:
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
    data = payload["data"]["data"]

    # Render as YAML-ish block (2-space indent friendly)
    rendered = "\n".join(f"{k}: {json.dumps(v) if isinstance(v, str) else v}" for k, v in data.items())

    cache[key] = rendered
    return rendered


def repl(m):
    path = m.group(1)
    field = m.group(2)

    if field:
        return vault_kv_get_field(path, field)
    else:
        return vault_kv_get_all(path)


sys.stdout.write(pat.sub(repl, data))
