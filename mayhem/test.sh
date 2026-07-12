#!/usr/bin/env bash
#
# mayhem/test.sh — RUN golisp's upstream test suite (pre-built by mayhem/build.sh
# as mayhem-build/golisp.test). TestParse (parser known-answer cases) + TestOps
# (golden-output oracle over testdata/*.lisp vs *.out/*.err). Emits CTRF.
set -uo pipefail
[ -n "${SOURCE_DATE_EPOCH:-}" ] || unset SOURCE_DATE_EPOCH
: "${MAYHEM_JOBS:=$(nproc)}"
cd "$SRC"

# emit_ctrf <tool> <passed> <failed> [skipped] [pending] [other]
emit_ctrf() {
  local tool="$1" passed="$2" failed="$3" skipped="${4:-0}" pending="${5:-0}" other="${6:-0}"
  local tests=$(( passed + failed + skipped + pending + other ))
  cat > "${CTRF_REPORT:-$SRC/ctrf-report.json}" <<JSON
{
  "results": {
    "tool": { "name": "$tool" },
    "summary": {
      "tests": $tests,
      "passed": $passed,
      "failed": $failed,
      "pending": $pending,
      "skipped": $skipped,
      "other": $other
    }
  }
}
JSON
  printf 'CTRF {"results":{"tool":{"name":"%s"},"summary":{"tests":%d,"passed":%d,"failed":%d,"pending":%d,"skipped":%d,"other":%d}}}\n' \
    "$tool" "$tests" "$passed" "$failed" "$pending" "$skipped" "$other"
  [ "$failed" -eq 0 ]
}

RUNNER="$SRC/mayhem-build/golisp.test"
if [ ! -x "$RUNNER" ]; then
  echo "FATAL: $RUNNER missing — mayhem/build.sh should have built it" >&2
  emit_ctrf "go-test" 0 1
  exit 1
fi

LOG=/tmp/golisp-test.log
# Run from $SRC so testdata/ and lib/ resolve. -test.v prints one --- PASS/FAIL per test.
"$RUNNER" -test.v 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

passed=$(grep -c '^--- PASS:' "$LOG" || true)
failed=$(grep -c '^--- FAIL:' "$LOG" || true)
skipped=$(grep -c '^--- SKIP:' "$LOG" || true)
# A crashed/paniced runner may print no per-test lines — count it as a failure.
if [ "$rc" -ne 0 ] && [ "$failed" -eq 0 ]; then
  failed=1
fi

emit_ctrf "go-test" "$passed" "$failed" "$skipped"
