#!/usr/bin/make -f

target_file?=main.asm

build: build_x32

run:
	./main.out

build_x32:
	nasm -f elf $(target_file)  -o main.o # output main.o
	ld -V -m elf_i386 -o main.out main.o  # input main.o, output main.out

build_x64:
	nasm -f elf64 $(target_file)  # output main.o
	ld -V -o main.out main.o  # input main.o, output main.out

format:
ifeq (,$(wildcard ./formatter.out))
	go build formatter.go
	mv formatter formatter.out
endif
	./formatter.out -ii 16 -ci 48 $(target_file)

debug:
	gdb main.out -x debug.gdb

clean:
	rm *.o *.out

docs:
	pdflatex README.tex

