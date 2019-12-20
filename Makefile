.PHONY: run-day%

input/:
	mkdir -p input

input/%.txt: input/
	@test $${AOC_SESSION?Please set environment variable AOS_SESSION}
	curl -f -b session=${AOC_SESSION} https://adventofcode.com/2019/day/$(@:input/%.txt=%)/input -o $@

# Day 1: C

day1%.out: day1%.c
	gcc -o $@ $<

run-day1a: day1a.out input/1.txt
	./day1a.out < input/1.txt

run-day1b: day1b.out input/1.txt
	./day1b.out < input/1.txt

# Day 2: C++

day2%.out: day2%.cpp
	g++ -o $@ $<

run-day2a: day2a.out input/2.txt
	./day2a.out < input/2.txt

run-day2b: day2b.out input/2.txt
	./day2b.out < input/2.txt

# Day 3: Prolog

run-day3a: day3a.pro input/3.txt
	swipl day3a.pro < input/3.txt

run-day3b: day3b.pro input/3.txt
	swipl --stack_limit=4G day3b.pro < input/3.txt

# Day 4: JavaScript

run-day4a: day4a.js input/4.txt
	node day4a.js < input/4.txt

run-day4b: day4b.js input/4.txt
	node day4b.js < input/4.txt

# Day 5: C++ (continuation of day 2)

day5%.out: day5%.cpp
	g++ -o $@ $<

run-day5a: day5a.out input/5.txt
	./day5a.out < input/5.txt

run-day5b: day5b.out input/5.txt
	./day5b.out < input/5.txt

# Day 6: Free choice: Python

run-day6a: day6a.py input/6.txt
	python day6a.py < input/6.txt

run-day6b: day6b.py input/6.txt
	python day6b.py < input/6.txt

# Day 7: C++ (continuation of day 2)

day7%.out: day7%.cpp
	g++ -o $@ $<

run-day7a: day7a.out input/7.txt
	./day7a.out < input/7.txt

run-day7b: day7b.out input/7.txt
	./day7b.out < input/7.txt

# Day 8: Spreadsheet: LibreOffice
# I have no idea how to automate this.

# Day 9: C++ (continuation of day 2)

day9%.out: day9%.cpp
	g++ -o $@ $<

run-day9a: day9a.out input/9.txt
	./day9a.out < input/9.txt

run-day9b: day9b.out input/9.txt
	./day9b.out < input/9.txt

# Day 10: Scheme

run-day10a: day10a.sps input/10.txt
	plt-r6rs day10a.sps < input/10.txt

run-day10b: day10b.sps input/10.txt
	plt-r6rs day10b.sps < input/10.txt

# Day 11: C++ (continuation of day 2)

day11%.out: day11%.cpp
	g++ -o $@ $<

run-day11a: day11a.out input/11.txt
	./day11a.out < input/11.txt

run-day11b: day11b.out input/11.txt
	./day11b.out < input/11.txt

# Day 12: Smalltalk

run-day12a: day12a.st input/12.txt
	gst day12a.st < input/12.txt

run-day12b: day12b.st input/12.txt
	gst day12b.st < input/12.txt

# Day 13: C++ (continuation of day 2)

day13%.out: day13%.cpp
	g++ -o $@ $<

run-day13a: day13a.out input/13.txt
	./day13a.out < input/13.txt

run-day13b: day13b.out input/13.txt
	./day13b.out < input/13.txt

# Day 14: Perl 5

run-day14a: day14a.pl input/14.txt
	perl day14a.pl < input/14.txt

run-day14b: day14b.pl input/14.txt
	perl day14b.pl < input/14.txt

# Day 15: C++ (continuation of day 2)

day15%.out: day15%.cpp
	g++ -o $@ $<

run-day15a: day15a.out input/15.txt
	./day15a.out < input/15.txt

run-day15b: day15b.out input/15.txt
	./day15b.out < input/15.txt

# Day 16: Clojure

run-day16a: day16a.clj input/16.txt
	clojure day16a.clj < input/16.txt

run-day16b: day16b.clj input/16.txt
	clojure day16b.clj < input/16.txt

# Day 17: C++ (continuation of day 2)

day17%.out: day17%.cpp
	g++ -o $@ $<

run-day17a: day17a.out input/17.txt
	./day17a.out < input/17.txt

run-day17b: day17b.out input/17.txt
	./day17b.out < input/17.txt

# Day 18: Ruby

run-day18a: day18a.rb input/18.txt
	ruby day18a.rb < input/18.txt

run-day18b: day18b.rb input/18.txt
	ruby day18b.rb < input/18.txt
