ALL_SOURCES=$(wildcard \
com/dongxiguo/hoo/*.hx \
com/dongxiguo/hoo/*/*.hx \
com/dongxiguo/hoo/*/*/*.hx)

all release.zip: \
haxelib.xml \
haxedoc.xml \
run.n \
LICENSE \
$(ALL_SOURCES)

ifeq ($(OS),Windows_NT)
cygpath=$(shell cygpath $(foreach f,$(1),"$(f)"))
else
cygpath=$(1)
endif

run.n: $(wildcard $(call cygpath,$(shell haxelib run haxelib-run print-lib-path)com/dongxiguo/utils/*.hx))
	haxe -main com.dongxiguo.utils.HaxelibRun -lib haxelib-run -neko $@

release.zip:
	 zip --filesync $@ $^

clean:
	$(RM) -r bin release.zip run.n haxedoc.xml

test: test-neko test-node bin/HooTest.swf

test-neko: bin/HooTest.n
	neko $<

test-node: bin/HooTest.js
	node bin/HooTest.js

bin/HooTest.n: $(wildcard tests/*.hx) $(ALL_SOURCES) | bin
	haxe -neko $@ -main tests.HooTest

bin/HooTest.swf: $(wildcard tests/*.hx) $(ALL_SOURCES) | bin
	haxe -swf $@ -main tests.HooTest

bin/HooTest.js: $(wildcard tests/*.hx) $(ALL_SOURCES) | bin
	haxe -js $@ -main tests.HooTest

haxedoc.xml: $(ALL_SOURCES)
	haxe -xml $@ $^

bin:
	mkdir $@

install: release.zip
	haxelib test release.zip

.PHONY: all clean test-neko test-node test install
