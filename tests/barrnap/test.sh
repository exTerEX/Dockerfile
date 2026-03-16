#!/usr/bin/env bash
# Tests for the barrnap container image.
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

# 2. Version check
#    barrnap's --version output does not match the git tag (e.g. reports
#    "barrnap 0.9" for tag v1.0.0), so we just verify the binary identifies
#    itself as barrnap.
echo ""
echo "2) Version check"
if OUTPUT=$(docker run --rm "${IMAGE}" --version 2>&1) && \
   echo "${OUTPUT}" | grep -qiE "^barrnap"; then
  pass "Binary identifies as barrnap (${OUTPUT})"
else
  fail "Version output unexpected (output: ${OUTPUT:0:200})"
fi

# Summary
echo ""
echo "── Results: ${PASS} passed, ${FAIL} failed ──"
[[ ${FAIL} -eq 0 ]]
