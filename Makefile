VERSION:=0.1.3-2
CXXFLAGS:=-std=gnu++11 -g -Iproto -I/usr/local/include
LDFLAGS:=-L/usr/local/lib -lzap -lkj -pthread
ZAP_TEST:=../zap_test
PWD:=$(shell pwd)
#CXX:=g++-4.7

export PATH:=bin:$(PATH)
export LUA_PATH:=$(PWD)/?.lua;$(PWD)/proto/?.lua;$(PWD)/lua/?.lua;$(PWD)/proto/?.lua;$(PWD)/tests/?.lua;$(PWD)/$(ZAP_TEST)/?.lua;$(LUA_PATH);;
export VERBOSE

compiled: proto/example.zap proto/enums.zap
	zap compile -oc++ $+

test.schema.txt: proto/enums.zap proto/example.zap
	zap compile -oecho $+ > /tmp/zap.bin
	zap decode proto/schema.zap CodeGeneratorRequest > $@ < /tmp/zap.bin

cpp/example_zap.o: proto/example.zap.c++ compiled
	$(CXX) -c $(CXXFLAGS) $< -o $@

cpp/enums_zap.o: proto/enums.zap.c++ compiled
	$(CXX) -c $(CXXFLAGS) $< -o $@

cpp/main.o: cpp/main.c++ compiled
	$(CXX) -c $(CXXFLAGS) $< -o $@

cpp/main: cpp/main.o cpp/example_zap.o cpp/enums_zap.o
	$(CXX) $(CXXFLAGS) -o $@ $+ $(LDFLAGS)

proto/example_zap.lua: proto/example.zap proto/enums.zap proto/struct.zap proto/lua.zap
	zap compile -obin/zapc-lua $+

test: clean proto/example_zap.lua
	tests/run_tests.sh

test1:
	zap compile -olua $(ZAP_TEST)/test.zap ../zap/c++/src/zap/c++.zap
	$(MAKE) -C $(ZAP_TEST) ZAP_TEST_APP=`pwd`/bin/lua-zap-test

all: cpp/main

clean:
	-rm proto/example.zap.c++ proto/example.zap.h cpp/*.o cpp/main test.schema.lua proto/example_zap.lua a.data c.data test.schema.txt *.data

tag_and_pack:
ifeq ($(shell git tag --sort=version:refname|tail -n 1), v$(VERSION))
	@echo "Need to \"make version\" first"
	@exit 1
endif
	@echo "Add git tag v$(VERSION)?"
	@read -r FOO
	git tag -f v$(VERSION)
	@echo "Push tags?"
	@read -r FOO
	git push --tags
	@echo "Build package?"
	@read -r FOO
	cp lua-zap.rockspec lua-zap-$(VERSION).rockspec
	luarocks pack lua-zap-$(VERSION).rockspec

version:
	@echo "Old version is \"$(VERSION)\""
	@echo "Enter new version: "
	@# The use of variable "new_version" ($$new_version) should be in the same line as where it gets its value
	@read new_version; perl -pi -e "s/$(VERSION)/$$new_version/" Makefile bin/zapc-lua lua-zap.rockspec
	git add Makefile bin/zapc-lua lua-zap.rockspec
	git commit -m 'Bump version number'

release: tag_and_pack

release_clean:
	-rm -f lua-zap-*.rockspec *.rock

.PHONY: all clean test release
