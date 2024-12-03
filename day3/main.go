package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
)

func main() {
	inputBytes, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

	input := string(inputBytes)
	part1(input)
	part2(input)
}

func part1(input string) {
	// This regex is more confusing to mentally parse than the damn input.
	reg := regexp.MustCompile(`mul\((?P<left>\d{1,3}),(?P<right>\d{1,3})\)`)
	leftIndex := reg.SubexpIndex("left")
	rightIndex := reg.SubexpIndex("right")
	matches := reg.FindAllStringSubmatch(input, -1)

	acc := 0
	for _, match := range matches {
		left, err := strconv.Atoi(match[leftIndex])
		if err != nil {
			panic(err)
		}
		right, err := strconv.Atoi(match[rightIndex])
		if err != nil {
			panic(err)
		}
		acc += left * right
	}

	fmt.Printf("Part 1: %d\n", acc)
}

func part2(input string) {
	reg := regexp.MustCompile(`((?P<func>(do|don't))\(\))|(mul\((?P<left>\d{1,3}),(?P<right>\d{1,3})\))`)
	leftIndex := reg.SubexpIndex("left")
	rightIndex := reg.SubexpIndex("right")
	funcIndex := reg.SubexpIndex("func")
	matches := reg.FindAllStringSubmatch(input, -1)

	acc := 0
	do := true
	for _, match := range matches {
		fun := match[funcIndex]
		switch fun {
		case "do":
			do = true
			continue
		case "don't":
			do = false
			continue
		case "": // mul
		default:
			panic(fun)
		}

		if !do {
			continue
		}

		left, err := strconv.Atoi(match[leftIndex])
		if err != nil {
			panic(err)
		}
		right, err := strconv.Atoi(match[rightIndex])
		if err != nil {
			panic(err)
		}
		acc += left * right
	}

	fmt.Printf("Part 2: %d", acc)
}
