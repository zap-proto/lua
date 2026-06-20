# lua-zap

Code structure
==============

    ├── bin         ZAP compiler's plug-ins and ZAP schema file
    ├── zap       lua-zap library file (including compiler)
    ├── cpp         cpp files used for testing lua-zap
    ├── example     examples for how to use lua-zap
    ├── lua         other lua files
    ├── proto       all protos
    └── tests       test files

Debugging
=========

Set environment variable `VERBOSE` to 1 enables debug mode. Compiler will generate more debug info and the following files:

* `test.schema.lua` This is the schema passed from ZAP compiler to lua plug-in. ZAP text presentation has been translated to lua file.
* `lua.schema.json` Schema that lua-zap compiler used

Compiling proto files
=====================

All proto files including imported proto files should be compiled together. Output file will use first input proto file's name plus a "_zap.lua" suffix. For example:

    zap compile -olua message.zap constants.zap

Output file will be `message_zap.lua`

When developing, you may need to run the following command. This specifies which zapc-lua to use.

    VERBOSE=1 zap compile -o ../bin/zapc-lua example.zap enums.zap lua.zap struct.zap

How to add a new naming function
================================

* add a new naming function in zap/util.lua
* add a test case in tests/02-util.lua
* test new naming function by `make test`
* add your naming function to "naming_funcs" table in "zap/compile.lua" using this kind of format: `name = function`. 'name' is what you will write in ZAP file using "$Lua.naming" annotation. 'function' is you actual naming function
* add a new enum in proto/enums.zap.
* add a test case in tests/11-handwritten.lua (see test_lower_space_naming)
* update lua/handwritten_zap.lua using `vimdiff lua/handwritten_zap.lua proto/example_zap.lua`

Generated code
===============

`calc_size`             - calculate size need for serialization using given input data, header size included
`calc_size_struct`      - calculate size need for serialization using given input data, header size not included
