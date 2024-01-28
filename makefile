#!/usr/bin/make -f
SHELL=/bin/sh
cc = gcc
cc_standard = -std=c17
cc_optimization = -Ofast -march=native
cc_warnings = -Werror -Wall -Wextra -Wpedantic -Wshadow -Wconversion \
	-pedantic-errors -Wmissing-prototypes -Wmissing-prototypes \
	-Wstrict-prototypes -Wold-style-definition -O3 -g
cc_link = -lgmp
target_file?=main.c

main: $(target_file)
	${cc} ${cc_standard} ${cc_optimization} ${cc_warnings} $^ -o $@ ${cc_link}

run:
	./main

clean:
	rm *.o *.out

scheme:
	d2 -l elk --pad 0 --scale 0.7 ./compilation.d2 compilation.svg

docs:
	pdflatex README.tex

astyle:
	astyle -rv --style=linux --indent=force-tab=4 --delete-empty-lines \
	--break-closing-braces --max-code-length=80 --lineend=linux --ascii \
	"*.c"

build_x32:
	nasm -f elf -o a.o $(target_file)
	ld -V -m elf_i386 -o a.out a.o
