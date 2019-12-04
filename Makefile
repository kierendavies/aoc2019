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
