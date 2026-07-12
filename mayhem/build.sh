#!/usr/bin/env bash
#
# mayhem/build.sh — build the golisp go-fuzz harness as a sanitized libFuzzer
# binary (OSS-Fuzz Go path: go-fuzz-build -libfuzzer + clang link) and pre-build
# the upstream test binary that mayhem/test.sh runs.
#
# AIR-GAPPED CONTRACT (SPEC §6.5): the PATCH tier re-runs THIS script OFFLINE.
# GOPROXY resolves from the in-image module cache first, network last.
set -euo pipefail

[ -n "${SOURCE_DATE_EPOCH:-}" ] || unset SOURCE_DATE_EPOCH

: "${CC:=clang}" ; : "${CXX:=clang++}" ; : "${LIB_FUZZING_ENGINE:=-fsanitize=fuzzer}"
# OSS-Fuzz Go path is ASan-only for the libFuzzer link.
: "${SANITIZER_FLAGS=-fsanitize=address}"
: "${MAYHEM_JOBS:=$(nproc)}"
# DWARF < 4 contract (§6.2 item 10): gc emits DWARF4; the clang-compiled cgo shim
# would land DWARF-5 first — thread -gdwarf-3 through CGO and the final link.
: "${GO_DEBUG_FLAGS:=-g -gdwarf-3}"
export GOEXPERIMENT=nodwarf5
export CGO_CFLAGS="${CGO_CFLAGS:-$GO_DEBUG_FLAGS}" CGO_CXXFLAGS="${CGO_CXXFLAGS:-$GO_DEBUG_FLAGS}"
export CC CXX LIB_FUZZING_ENGINE SANITIZER_FLAGS MAYHEM_JOBS GO_DEBUG_FLAGS

# Resolve modules offline-first from the in-image cache; network only as a fallback.
export GOFLAGS="${GOFLAGS:--mod=mod}"
export GOPROXY="${GOPROXY:-file://$(go env GOMODCACHE)/cache/download,https://proxy.golang.org,direct}"

cd "$SRC"
go version

# go-fuzz-build needs go-fuzz-dep on the module graph (resolves from cache offline).
go get github.com/dvyukov/go-fuzz/go-fuzz-dep

HARNESS_DIR="mayhem/fuzz"
TARGET="main"   # preserve the old Mayhemfile target name for corpus continuity

mkdir -p "$SRC/mayhem-build"
echo "=== building $TARGET (go-fuzz-build -libfuzzer) ==="
(
  cd "$SRC/$HARNESS_DIR"
  go-fuzz-build -libfuzzer -o "$SRC/mayhem-build/$TARGET.a"
)
$CXX $SANITIZER_FLAGS $LIB_FUZZING_ENGINE $GO_DEBUG_FLAGS "$SRC/mayhem-build/$TARGET.a" -o "/mayhem/$TARGET"
echo "built /mayhem/$TARGET"

# Pre-build the upstream test suite (normal flags, no sanitizers) so mayhem/test.sh
# only RUNS it. TestParse + TestOps (golden testdata/*.lisp[.out|.err] oracle).
echo "=== building upstream test binary (go test -c) ==="
go test -c -o "$SRC/mayhem-build/golisp.test" .
echo "built $SRC/mayhem-build/golisp.test"

echo "build.sh complete"
