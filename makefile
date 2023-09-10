#!/usr/bin/make -f

target_file?=main.asm

build_x32:
	nasm -f elf -o a.o $(target_file)
	ld -V -m elf_i386 -o a.out a.o

build_x64:
	nasm -f elf64 -o a.o $(target_file)
	ld -V -o a.out a.o

format:
ifeq (,$(wildcard ./formatter.out))
	go build formatter.go
	mv formatter formatter.out
endif
	./formatter.out -ii 16 -ci 48 $(target_file)

debug:
	gdb a.out -x debug.gdb

clean:
	rm a.o *.out

docs:
	pdflatex README.tex
