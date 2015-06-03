build/main.tap: build/main.bin | build
	bin2tap $< $@ 32768

build/main.bin: src/main.s src/* | build
	sjasmplus $< --lst=build/main.lst

build:
	mkdir -p build

run:
	open -a fuse build/main.tap
