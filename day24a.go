package main

import (
	_ "bufio"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

type Tiles uint64

type Layout struct {
	W int
	H int
	T Tiles
}

func ParseLayout(bs []byte) Layout {
	l := Layout{}
	var mask Tiles = 1
	for _, b := range bs {
		switch b {
		case '#':
			l.T |= mask
			fallthrough
		case '.':
			mask <<= 1
			if l.H == 0 {
				l.W++
			}
		case '\n':
			l.H++
		}
	}
	return l
}

func (l Layout) Get(x, y int) bool {
	var mask Tiles = 1 << Tiles(y*l.W+x)
	return l.T&mask != 0
}

func (l Layout) Tick() Layout {
	l2 := Layout{W: l.W, H: l.H}
	var mask Tiles = 1
	for y := 0; y < l.H; y++ {
		for x := 0; x < l.W; x++ {
			c := 0
			if x > 0 && l.Get(x-1, y) {
				c++
			}
			if x < l.W-1 && l.Get(x+1, y) {
				c++
			}
			if y > 0 && l.Get(x, y-1) {
				c++
			}
			if y < l.H-1 && l.Get(x, y+1) {
				c++
			}

			if c == 1 || (c == 2 && !l.Get(x, y)) {
				l2.T |= mask
			}

			mask <<= 1
		}
	}
	return l2
}

func (l Layout) String() string {
	sb := &strings.Builder{}
	for y := 0; y < l.H; y++ {
		for x := 0; x < l.W; x++ {
			if l.Get(x, y) {
				sb.WriteByte('#')
			} else {
				sb.WriteByte('.')
			}
		}
		sb.WriteByte('\n')
	}
	return sb.String()
}

func main() {
	bs, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}

	l := ParseLayout(bs)
	seen := make(map[Layout]struct{})

	for {
		_, ok := seen[l]
		if ok {
			break
		}
		seen[l] = struct{}{}
		l = l.Tick()
	}

	fmt.Println(l.T)
}
