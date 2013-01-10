all: release.zip

ALL_SOURCES=$(wildcard \
com/dongxiguo/hoo/*.hx \
com/dongxiguo/hoo/*/*.hx \
com/dongxiguo/hoo/*/*/*.hx)

release.zip: \
haxelib.xml \
haxedoc.xml \
LICENSE \
$(ALL_SOURCES)
	 zip --filesync $@ $^

clean:
	$(RM) -r bin release.zip haxedoc.xml

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

.PHONY: all clean test-neko test-node test
