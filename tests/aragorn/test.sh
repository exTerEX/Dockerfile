#!/usr/bin/env bash
# Functional tests for the aragorn container image.
# Usage: ./test.sh <image> <expected_version>
#
# Exit codes:
#   0 – all tests passed
#   1 – one or more tests failed
set -euo pipefail

IMAGE="${1:?Usage: $0 <image> <expected_version>}"
EXPECTED_VERSION="${2:?Usage: $0 <image> <expected_version>}"

PASS=0
FAIL=0

pass() { ((++PASS)); echo "  ✅  $1"; }
fail() { ((++FAIL)); echo "  ❌  $1"; }

echo "── Testing ${IMAGE} (expected v${EXPECTED_VERSION}) ──"

# -------------------------------------------------------------------
# 1. Version / help banner
# -------------------------------------------------------------------
echo ""
echo "1) Version check"
# aragorn prints its version on stderr with -h; grep for the number
if OUTPUT=$(docker run --rm "${IMAGE}" -h 2>&1) && \
   echo "${OUTPUT}" | grep -qiE "ARAGORN v${EXPECTED_VERSION}"; then
  pass "Version string contains ${EXPECTED_VERSION}"
else
  fail "Version string missing (output: ${OUTPUT:0:200})"
fi

# -------------------------------------------------------------------
# 2. Entrypoint is functional (exit 0 with -h)
# -------------------------------------------------------------------
echo ""
echo "2) Entrypoint returns success with -h"
if docker run --rm "${IMAGE}" -h >/dev/null 2>&1; then
  pass "Exit code 0 with -h"
else
  fail "Non-zero exit code with -h"
fi

# -------------------------------------------------------------------
# 3. Detect tRNA in a minimal FASTA sequence
#    Use a well-known E. coli tRNA-fMet sequence.
# -------------------------------------------------------------------
echo ""
echo "3) Functional: detect tRNA in sample FASTA"
FASTA=">ecoli_tRNA_fMet
CGCGGGGTGGAGCAGCCTGGTAGCTCGTCGGGCTCATAACCCGAAGGTCG
TCGGTTCAAATCCGGCCCCCGCAACCA"

TMPDIR=$(mktemp -d)
echo "${FASTA}" > "${TMPDIR}/sample.fa"
chmod 755 "${TMPDIR}"
chmod 644 "${TMPDIR}/sample.fa"

if OUTPUT=$(docker run --rm -v "${TMPDIR}:/data" "${IMAGE}" -t /data/sample.fa 2>&1) && \
   echo "${OUTPUT}" | grep -qiE "trna|gene"; then
  pass "tRNA detected in sample sequence"
else
  fail "No tRNA detected (output: ${OUTPUT:0:300})"
fi

rm -rf "${TMPDIR}"

# -------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------
echo ""
echo "── Results: ${PASS} passed, ${FAIL} failed ──"
[[ ${FAIL} -eq 0 ]]
