.PHONY: run-day%

input/:
	mkdir -p input

input/%.txt: input/
	@test $${AOC_SESSION?Please set environment variable AOS_SESSION}
	curl -f -b session=${AOC_SESSION} https://adventofcode.com/2019/day/$(@:input/%.txt=%)/input -o $@

day1%.out: day1%.c
	gcc -o $@ $<

run-day1a: day1a.out input/1.txt
	./day1a.out < input/1.txt

run-day1b: day1b.out input/1.txt
	./day1b.out < input/1.txt
