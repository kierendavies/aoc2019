.PHONY: run-day%

input/:
	mkdir -p input

input/%.txt: input/
	@test $${AOC_SESSION?Please set environment variable AOS_SESSION}
	curl -f -b session=${AOC_SESSION} https://adventofcode.com/2019/day/$(@:input/%.txt=%)/input -o $@

day1a.out: day1a.c
	gcc -o day1a.out day1a.c

run-day1a: day1a.out input/1.txt
	./day1a.out < input/1.txt
