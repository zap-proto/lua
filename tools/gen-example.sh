#!/bin/bash
#
# Generate proto/example_zap.lua from the proto/*.zap schemas.
#
# The lua-zap compiler is a schema-compiler plugin: it consumes a Cap'n Proto
# CodeGeneratorRequest, not raw .zap text. The canonical front-end that parses
# .zap files and emits that request is the `capnp` tool. This script drives it:
#
#   1. capnp compile  proto/*.zap        -> binary CodeGeneratorRequest
#   2. capnp decode   schema.zap         -> textual request
#   3. util.parse_zap_decode_txt + compile.compile (pure Lua, this repo)
#                                        -> proto/example_zap.lua
#
# Step 3 is exactly what bin/zapc-lua does after the front-end; here we invoke
# the same `zap.util` / `zap.compile` entry points directly so generation has a
# single, scriptable path for both humans and CI.
#
# example.zap is listed first so util.get_output_name() yields proto/example_zap.

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
export LUA_PATH="$ROOT/?.lua;$ROOT/lua/?.lua;$ROOT/proto/?.lua;$ROOT/vendor/?.lua;${LUA_PATH:-};;"

# example.zap first so util.get_output_name() yields proto/example_zap.
PROTOS=(proto/example.zap proto/enums.zap proto/struct.zap proto/lua.zap)

if ! command -v capnp >/dev/null 2>&1; then
    echo "gen-example: 'capnp' (Cap'n Proto) not found on PATH" >&2
    exit 1
fi

REQ=$(mktemp)
TXT=$(mktemp)
trap 'rm -f "$REQ" "$TXT"' EXIT

# Run from ROOT with proto/-prefixed paths so requestedFiles keep that prefix,
# placing the generated module at proto/example_zap.lua. capnp resolves each
# file's relative imports from its own directory, so cross-proto imports work.
( cd "$ROOT" && capnp compile -o- "${PROTOS[@]}" ) > "$REQ"
capnp decode "$ROOT/bin/schema.zap" CodeGeneratorRequest < "$REQ" > "$TXT"

luajit - "$TXT" "$ROOT" <<'LUA'
local util    = require "zap.util"
local compile = require "zap.compile"

local txt  = assert(arg[1], "internal: missing txt arg")
local root = assert(arg[2], "internal: missing root arg")
local lua_schema = assert(util.parse_zap_decode_txt(txt))
local schema = assert(assert(loadstring(lua_schema))())
schema.__compiler = "lua-zap(decoded by capnp)"

local res = compile.compile(schema)
local out = root .. "/" .. util.get_output_name(schema) .. ".lua"
util.write_file(out, res)
io.write("gen-example: wrote ", out, " (", #res, " bytes)\n")
LUA
