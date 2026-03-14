#!/usr/bin/env bash
# Tests for the trnascan-se container image.
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
if docker run --rm --entrypoint tRNAscan-SE "${IMAGE}" -h >/dev/null 2>&1; then
  pass "Exit code 0 with -h"
else
  fail "Non-zero exit code with -h"
fi

# 2. Version check
#    Some releases omit the patch digit (e.g. "2.0" instead of "2.0.0"),
#    so we also accept the major.minor prefix when patch is 0.
echo ""
echo "2) Version check"
if OUTPUT=$(docker run --rm --entrypoint tRNAscan-SE "${IMAGE}" -h 2>&1) && \
   echo "${OUTPUT}" | grep -qiE "tRNAscan-SE ${EXPECTED_VERSION}( |$)"; then
  pass "Version string contains ${EXPECTED_VERSION}"
elif TRIMMED="${EXPECTED_VERSION%.0}" && [[ "$TRIMMED" != "$EXPECTED_VERSION" ]] && \
   echo "${OUTPUT}" | grep -qiE "tRNAscan-SE ${TRIMMED}( |$)"; then
  pass "Version string contains ${TRIMMED} (trailing .0 omitted by program)"
else
  fail "Version string missing (output: ${OUTPUT:0:200})"
fi

# Summary
echo ""
echo "── Results: ${PASS} passed, ${FAIL} failed ──"
[[ ${FAIL} -eq 0 ]]
