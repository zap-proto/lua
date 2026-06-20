#!/bin/bash

# Run the lua-zap unit tests.
#
# Tests 02 (util) and 03 (compile) are pure-Lua and always run.
# Tests 01 (sanity) and 10 (encode-decode) need the generated module
# proto/example_zap.lua, which is produced from proto/*.zap by the ZAP schema
# compiler. If the compiler is not on PATH we skip those two with a note rather
# than report a false pass.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
export LUA_PATH="$ROOT/?.lua;$ROOT/lua/?.lua;$ROOT/proto/?.lua;$ROOT/tests/?.lua;$ROOT/vendor/?.lua;$LUA_PATH;;"
export PATH="$ROOT/bin:$PATH"

GEN="$ROOT/proto/example_zap.lua"
SKIP_GEN=""

if [ ! -f "$GEN" ]; then
    if command -v zap >/dev/null 2>&1; then
        ( cd "$ROOT" && zap compile -obin/zapc-lua \
            proto/example.zap proto/enums.zap proto/struct.zap proto/lua.zap )
    fi
fi

if [ ! -f "$GEN" ]; then
    SKIP_GEN=1
    echo "NOTE: proto/example_zap.lua not generated (no 'zap' schema compiler on PATH);"
    echo "      skipping tests/01-sanity.lua and tests/10-encode-decode.lua."
fi

rc=0
for file in "$ROOT"/tests/*.lua
do
    base=$(basename "$file")
    if [ -n "$SKIP_GEN" ] && { [ "$base" = "01-sanity.lua" ] || [ "$base" = "10-encode-decode.lua" ]; }; then
        echo
        echo "Skipping $base (needs proto/example_zap.lua)"
        continue
    fi
    echo
    echo "Running $base..."
    luajit "$file" || rc=1
done

exit $rc
