package = "lua-zap"
version = "0.1.3-4"
source = {
   url = "git://github.com/zap-proto/lua",
   tag = "v0.1.3-4",
}
description = {
   summary = "Lua-zap is a pure lua implementation of zap based on LuaJIT.",
   detailed = [[
       Lua-zap is a pure lua implementation of zap based on LuaJIT.
   ]],
   homepage = "https://github.com/zap-proto/lua",
   license = "BSD",
}
dependencies = {
   "lua ~> 5.1",     -- in fact, this should be "luajit >= 2.1.0"
   "lua-cjson >= 2.1.0",   -- optional: schema/debug JSON dumps
}
build = {
   type = "builtin",
   modules = {
      zap = "zap.lua",
      ['zap.compile'] = "zap/compile.lua",
      ['zap.util'] = "zap/util.lua",
      -- vendored test framework (lunitx), see vendor/
      ['lunit'] = "vendor/lunit.lua",
      ['lunit.console'] = "vendor/lunit/console.lua",
      ['lunitx'] = "vendor/lunitx.lua",
      ['lunitx.atexit'] = "vendor/lunitx/atexit.lua",
   },
   install = {
      bin = {
         ['zapc-lua'] = "bin/zapc-lua",
         ['zapc-echo'] = "bin/zapc-echo",
         ['schema.zap'] = "bin/schema.zap",
      }
   }
}
