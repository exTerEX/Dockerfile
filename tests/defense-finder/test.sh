#!/usr/bin/env bash
# Tests for the defense-finder container image.
# Usage: ./test.sh <image> <expected_version>
set -euo pipefail

IMAGE="${1:?Usage: $0 <image> <expected_version>}"
EXPECTED_VERSION="${2:?Usage: $0 <image> <expected_version>}"

PASS=0
FAIL=0

pass() { ((++PASS)); echo "  ✅  $1"; }
fail() { ((++FAIL)); echo "  ❌  $1"; }

echo "── Testing ${IMAGE} (expected v${EXPECTED_VERSION}) ──"

# 1. Help flag exits cleanly
echo ""
echo "1) Help flag"
if docker run --rm "${IMAGE}" --help >/dev/null 2>&1; then
  pass "Exit code 0 with --help"
else
  fail "Non-zero exit code with --help"
fi

# 2. Version check (defense-finder has no --version; query micromamba)
echo ""
echo "2) Version check"
if OUTPUT=$(docker run --rm --entrypoint micromamba "${IMAGE}" list -n base defense-finder 2>&1) && \
   echo "${OUTPUT}" | grep -qE "^\s*defense-finder[[:space:]]+${EXPECTED_VERSION}(\s|$)"; then
  pass "Installed version is ${EXPECTED_VERSION}"
else
  fail "Version mismatch (output: ${OUTPUT:0:200})"
fi

# 3. Help output mentions defense-finder
echo ""
echo "3) Help output sanity"
if OUTPUT=$(docker run --rm "${IMAGE}" --help 2>&1) && \
   echo "${OUTPUT}" | grep -qiE "defense.finder"; then
  pass "Help output mentions defense-finder"
else
  fail "Help output missing defense-finder reference (output: ${OUTPUT:0:200})"
fi

# Summary
echo ""
echo "── Results: ${PASS} passed, ${FAIL} failed ──"
[[ ${FAIL} -eq 0 ]]
