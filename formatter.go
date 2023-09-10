// $GOROOT/bin/go run $0 $@ ; exit
// this file was taken from @yamnikov-oleg github repository under MIT license:
// https://github.com/yamnikov-oleg/nasmfmt
// unfortunately, this project is no more maintained. now, aug 04 2023, there's
// only one version in pre-release stage, v0.1.
// this revision's commit hash: 127dbe8e72376c67d7dff89010ccfb49fc7b533e
// thank you, @yamnikov-oleg, for your work
// i couldn't find a better way to install your formatter other than copy this
// file. you could have made an archlinux PKGBUILD file, or something.
package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"
	"unicode/utf8"
)

var (
	insIndent     int
	commentIndent int
)

func init() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr,
			"Usage: %s [params] [file1 [file2 ...]]\nParameters:\n",
			os.Args[0])
		flag.PrintDefaults()
	}
	flag.IntVar(&insIndent, "ii", 8,
		"Indentation for instructions in spaces")
	flag.IntVar(&commentIndent, "ci", 40,
		"Indentation for comments in spaces")
}

type asmLine struct {
	label   string
	text    string
	comment string
}

var (
	mulSpaces   = regexp.MustCompile(`\s+`)
	commaSpaces = regexp.MustCompile(`,\s*`)
)

func indexRune(s []rune, rn rune) int {
	for i := range s {
		if s[i] == rn {
			return i
		}
	}
	return -1
}

func indexRuneAny(s []rune, any string) int {
	anyr := []rune(any)
	for i, rn := range s {
		if indexRune(anyr, rn) >= 0 {
			return i
		}
	}
	return -1
}

func runesRepeat(rep []rune, count int) []rune {
	ret := []rune{}
	for i := 0; i < count; i++ {
		ret = append(ret, rep...)
	}
	return ret
}

func noquotes(s, rep string) string {
	sr := []rune(s)
	repr := []rune(rep)
	outr := []rune{}
	for len(sr) > 0 {
		ind := indexRuneAny(sr, `"'`)
		if ind >= 0 {
			quote := sr[ind]
			ind2 := ind + 1 + indexRune(sr[ind+1:], quote)
			if ind2 < ind+1 {
				outr = append(outr, sr[:ind+1]...)
				sr = sr[ind+1:]
				continue
			}
			outr = append(outr, sr[:ind]...)
			outr = append(outr, runesRepeat(repr, ind2-ind+1)...)
			sr = sr[ind2+1:]
		} else {
			outr = append(outr, sr...)
			sr = nil
		}
	}
	return string(outr)
}

var dataPseudos = compilePseudoes()

func compilePseudoes() (ret []*regexp.Regexp) {
	var (
		raw = []string{"db", "dw", "dd", "dq", "ddq", "do", "dt"}
		re  = `(?:\s|^)%v(?:\s|")`
	)
	for _, p := range raw {
		ret = append(ret, regexp.MustCompile(fmt.Sprintf(re, p)))
	}
	return
}

func parseLabel(line string) (lbl string, rest string) {
	lbl = ""
	rest = line
	noq := noquotes(line, "x")
	ind := strings.Index(noq, ":")
	if ind >= 0 {
		lbl = strings.TrimSpace(line[:ind])
		rest = line[ind+1:]
	}
	for _, pseudo := range dataPseudos {
		inds := pseudo.FindStringIndex(noq)
		if len(inds) > 0 {
			ind := inds[0]
			lbl = strings.TrimSpace(line[:ind])
			rest = line[ind:]
		}
	}
	matched := regexp.MustCompile(`\S*\s+\S*`).MatchString(lbl)
	if matched {
		lbl, rest = "", line
	}
	return
}

func parseComment(line string) (cmt string, rest string) {
	noq := noquotes(line, "x")
	ind := strings.Index(noq, ";")
	if ind >= 0 {
		cmt = strings.TrimSpace(line[ind+1:])
		rest = line[:ind]
		return
	}
	return "", line
}

func parseLine(line string) *asmLine {
	l := &asmLine{}
	l.comment, line = parseComment(line)
	l.label, line = parseLabel(line)
	l.text = strings.TrimSpace(line)
	l.text = mulSpaces.ReplaceAllString(l.text, " ")
	l.text = commaSpaces.ReplaceAllString(l.text, ", ")
	return l
}

func (l *asmLine) empty() bool {
	return l.label == "" && l.text == "" && l.comment == ""
}

func (l *asmLine) print(w io.Writer) {
	var (
		space  = []byte{' '}
		newl   = []byte{'\n'}
		column = 0
	)
	if l.label != "" {
		w.Write([]byte(l.label))
		w.Write([]byte{':'})
		column += utf8.RuneCountInString(l.label) + 1
		if l.text != "" {
			w.Write(newl)
			column = 0
		}
	}
	if l.text != "" {
		w.Write(bytes.Repeat(space, insIndent))
		w.Write([]byte(l.text))
		column += insIndent
		column += utf8.RuneCountInString(l.text)
	}
	if l.comment != "" {
		if column != 0 {
			if column < commentIndent-1 {
				w.Write(bytes.Repeat(space,
					commentIndent-column-1))
			} else {
				w.Write(space)
			}
		}
		w.Write([]byte{';', ' '})
		w.Write([]byte(l.comment))
	}
	w.Write(newl)
}

func formatto(filename, outname string) error {
	var file *os.File
	var out *os.File
	if filename == "-" {
		file = os.Stdin
		out = os.Stdout
	} else {
		var err error
		file, err = os.Open(filename)
		if err != nil {
			return err
		}
		defer file.Close()
		out, err = os.Create(outname)
		if err != nil {
			return err
		}
		defer out.Close()
	}
	scanner := bufio.NewScanner(file)
	lastEmpty := false
	for scanner.Scan() {
		line := scanner.Text()
		asmLine := parseLine(line)
		if lastEmpty && asmLine.empty() {
			continue
		}
		asmLine.print(out)
		lastEmpty = asmLine.empty()
	}
	return nil
}

func format(filename string) error {
	outname := filename + "~"
	if err := formatto(filename, outname); err != nil {
		return err
	}
	if filename != "-" {
		if err := os.Rename(outname, filename); err != nil {
			return err
		}
	}
	return nil
}

func main() {
	flag.Parse()
	files := flag.Args()
	for _, fn := range files {
		err := format(fn)
		if err != nil {
			fmt.Println(err)
		}
	}
}
