jit.opt.start("loopunroll=1000", "maxrecord=5000", "maxmcode=1024")

package.path = "lua/?.lua;proto/?.lua;" .. package.path

local test_zap    = require "handwritten_zap"

local ffi           = require "ffi"
local test_zap    = require "handwritten_zap"
local zap         = require "zap"
local cjson         = require "cjson"

local times         = arg[1] or 1000000

local data = {
    i0 = 32,
    i1 = 16,
    i2 = 127,
    b0 = true,
    b1 = true,
    i3 = 65536,
    e0 = "enum3",
    s0 = {
        f0 = 3.14,
        f1 = 3.14159265358979,
    },
    l0 = { 28, 29 },
    t0 = "hello",
    e1 = "enum7",
}

local size = test_zap.T1.calc_size(data)
local buf = ffi.new("char[?]", size)
local bin = test_zap.T1.serialize(data)
local json_data = cjson.encode(data)
local tab = {}

function run4()
    return test_zap.T1.serialize(data, buf, size)
end

function run3()
    return test_zap.T1.serialize(data)
end

function run2()
    return cjson.encode(data)
end

function run4()
    return cjson.decode(json_data)
end

function run1()
    return test_zap.T1.parse(bin, tab)
end

print("Benchmarking ", times .. " times.")

local res

function bench(name, func)
    local t1 = os.clock()

    for i=1, times do
        res = func()
    end

    print(name, " Elapsed: ", (os.clock() - t1) .. "s")
end

bench("cjson encode", run2)
bench("zap encode", run3)
bench("cjson decode", run4)
--bench("zap-noalloc", run4)
bench("zap decode", run1)

--print(cjson.encode(res))
