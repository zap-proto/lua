#!/bin/bash

# Top-level test entry. The vendored lunitx framework lives under vendor/, so
# the only external tool the full suite needs is the `zap` schema compiler,
# used to generate proto/example_zap.lua for tests 01 and 10.
# tests/run_tests.sh generates that module when `zap` is on PATH and otherwise
# skips those two tests with a note rather than fail.

set -e
ROOT=$(cd "$(dirname "$0")" && pwd)
export PATH="$ROOT/bin:$PATH"

echo "[Unit tests]"
"$ROOT/tests/run_tests.sh"

echo "[Done]"
