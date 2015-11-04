TEST_FILES= test.pl

.PHONIES: build run clean

default: run

build:
	ocamlbuild -use-menhir src/main.native

run: build
	./main.native $(TEST_FILES)

clean:
	ocamlbuild -clean
