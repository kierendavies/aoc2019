package main

import (
	"math/bits"
	_ "bufio"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

const layoutSize = 5

type Layout uint64

func ParseLayout(bs []byte) Layout {
	var l Layout = 0
	var mask Layout = 1
	for _, b := range bs {
		switch b {
		case '#':
			l |= mask
			fallthrough
		case '.':
			fallthrough
		case '?':
			mask <<= 1
		}
	}
	return l
}

func (l Layout) Get(x, y int) bool {
	var mask Layout = 1 << (y*layoutSize + x)
	return l&mask != 0
}

type RecursiveLayout struct {
	Pos []Layout
	Neg []Layout
}

func (rl RecursiveLayout) Get(lvl, x, y int) bool {
	if lvl < 0 {
		if -lvl > len(rl.Neg) {
			return false
		}
		return rl.Neg[-lvl-1].Get(x, y)
	}
	if lvl >= len(rl.Pos) {
		return false
	}
	return rl.Pos[lvl].Get(x, y)
}

func (rl RecursiveLayout) Tick() RecursiveLayout {
	lvlMin := -len(rl.Neg)
	for lvlMin < 0 && rl.Neg[-lvlMin-1] == 0 {
		lvlMin++
	}
	lvlMin--
	lvlMax := len(rl.Pos) - 1
	for rl.Pos[lvlMax] == 0 {
		lvlMax--
	}
	lvlMax++

	rl2 := RecursiveLayout{
		Pos: make([]Layout, lvlMax+1),
		Neg: make([]Layout, -lvlMin),
	}

	for lvl := lvlMin; lvl <= lvlMax; lvl++ {
		var mask Layout = 1
		for y := 0; y < 5; y++ {
			for x := 0; x < 5; x++ {
				if x == 2 && y == 2 {
					mask <<= 1
					continue
				}

				c := 0

				// Left
				if x == 0 {
					if rl.Get(lvl-1, 1, 2) {
						c++
					}
				} else if x == 3 && y == 2 {
					for yy := 0; yy < 5; yy++ {
						if rl.Get(lvl+1, 4, yy) {
							c++
						}
					}
				} else if rl.Get(lvl, x-1, y) {
					c++
				}

				// Right
				if x == 4 {
					if rl.Get(lvl-1, 3, 2) {
						c++
					}
				} else if x == 1 && y == 2 {
					for yy := 0; yy < 5; yy++ {
						if rl.Get(lvl+1, 0, yy) {
							c++
						}
					}
				} else if rl.Get(lvl, x+1, y) {
					c++
				}

				// Above
				if y == 0 {
					if rl.Get(lvl-1, 2, 1) {
						c++
					}
				} else if y == 3 && x == 2 {
					for xx := 0; xx < 5; xx++ {
						if rl.Get(lvl+1, xx, 4) {
							c++
						}
					}
				} else if rl.Get(lvl, x, y-1) {
					c++
				}

				// Below
				if y == 4 {
					if rl.Get(lvl-1, 2, 3) {
						c++
					}
				} else if y == 1 && x == 2 {
					for xx := 0; xx < 5; xx++ {
						if rl.Get(lvl+1, xx, 0) {
							c++
						}
					}
				} else if rl.Get(lvl, x, y+1) {
					c++
				}

				if c == 1 || (c == 2 && !rl.Get(lvl, x, y)) {
					if lvl < 0 {
						rl2.Neg[-lvl-1] |= mask
					} else {
						rl2.Pos[lvl] |= mask
					}
				}

				mask <<= 1
			}
		}
	}

	return rl2
}

func (rl RecursiveLayout) Count() int {
	c := 0
	for _, l := range rl.Neg {
		c += bits.OnesCount64(uint64(l))
	}
	for _, l := range rl.Pos {
		c += bits.OnesCount64(uint64(l))
	}
	return c
}

func (rl RecursiveLayout) String() string {
	sb := strings.Builder{}
	lvlMin := -len(rl.Neg)
	lvlMax := len(rl.Pos) - 1
	for lvl := lvlMin; lvl <= lvlMax; lvl++ {
		sb.WriteString(fmt.Sprintf("Depth %d:\n", lvl))
		for y := 0; y < layoutSize; y++ {
			for x := 0; x < layoutSize; x++ {
				if x == 2 && y == 2 {
					sb.WriteByte('?')
				} else if rl.Get(lvl, x, y) {
					sb.WriteByte('#')
				} else {
					sb.WriteByte('.')
				}
			}
			sb.WriteByte('\n')
		}
	}
	return sb.String()
}

func main() {
	bs, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}

	l := ParseLayout(bs)

	rl := RecursiveLayout{}
	rl.Pos = append(rl.Pos, l)

	for i := 0; i < 200; i++ {
		rl = rl.Tick()
	}
	fmt.Println(rl.Count())
}
