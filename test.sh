#!/usr/bin/env bash
file="$1"
pattern="$2"
echo "PERL"
echo $(tail -n 4 "$(time ./test.pl "$file" "$pattern")")
echo "NODE.JS"
echo $(tail -n 4 "$(time ./test.js "$file" "$pattern")")
echo "PYTHON"
echo $(tail -n 4 "$(time ./test.py "$file" "$pattern")")
echo "PYPY"
echo $(tail -n 4 "$(time pypy test.py "$file" "$pattern")")
echo "SED"
echo $(tail -n 4 "$(time sed -n "/$pattern/p" "$file")")
echo "AWK"
echo $(tail -n 4 "$(time awk "/$pattern/{ print \$0 }" "$file")")
echo "GREP"
echo $(tail -n 4 "$(time grep -n "$pattern" "$file")")
echo "LLS"
echo $(tail -n 4 "$(time ./main "$file" "$pattern")")
