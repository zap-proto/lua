
> **Docs:** [ZAP Lua SDK](https://zap-proto.dev/docs/sdks) · part of the [ZAP Protocol](https://zap-proto.io)

lua-zap
=============

[ZAP](https://zap-proto.io) is an insanely fast data interchange format and capability-based RPC system.

Lua-zap is a pure lua implementation of ZAP based on `LuaJIT`.

This project is still under early development and is not production-ready.

Synopsis
========
Suppose you have a ZAP file called example.zap. You can compile this file like this:

    $zap compile -olua example.zap

The default output file is `example_zap.lua`

    local example_zap = require "example_zap"

Check out example/AddressBook.zap and example/main.lua for how to use generated lua file.

Installation
============
To install lua-zap, you need to install ZAP <https://zap-proto.io>, LuaJIT <http://luajit.org/install.html> and luarocks <http://luarocks.org/en/Download> first.

`Currently, lua-zap only works with LuaJIT v2.1`. You can install LuaJIT v2.1 using the following commands:

    $git clone http://luajit.org/git/luajit-2.0.git
    $git checkout v2.1
    $make && sudo make install
    $sudo ln -sf luajit-2.1.0-alpha /usr/local/bin/luajit

Then you can install lua-zap using the following commands:

    $sudo luarocks install lua-zap

Let's compile an example file to test whether lua-zap was installed successfully:

    $zap compile -olua proto/example.zap proto/enums.zap proto/lua.zap proto/struct.zap

Normally, you should see no errors and a file named "proto/example_zap.lua" is generated.

How to use
==========
Please see the ZAP Lua SDK guide [here](https://zap-proto.dev/docs/sdks).

Testing
=======

The test framework (lunitx) is vendored under `vendor/`, so no extra install is
needed to run the unit tests:

    $tests/run_tests.sh

Tests `01-sanity` and `10-encode-decode` need the generated module
`proto/example_zap.lua`. The runner generates it with the `zap` schema compiler
if one is on `PATH`; otherwise it skips those two and runs the pure-Lua tests
(`02-util`, `03-compile`). `lua-cjson` is optional — it is only used for debug
output; install it with `luarocks install lua-cjson` if you want the schema
dumps.

Limitations
===========
* Currently, lua-zap only works with LuaJIT v2.1. This is because lua-zap needs 64 bit integer support and 64bit number bit operations, but only LuaJIT v2.1 provides a decent way to do all these. I'm working on LuaJIT 2.0/ Lua 5.1 / Lua 5.2 support, hopefully you can use lua-zap with your favorite lua soon.
* ZAP RPC is not implemented yet