package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type Map = [][]Tile // row then column

type Tile struct {
	Height int
	Row    int
	Column int
}

type Trail []*Tile

// Slow debug function
func (t Trail) MapString(hikeMap Map) string {
	out := strings.Builder{}

	for _, row := range hikeMap {
		for _, tile := range row {
			isInTrail := slices.ContainsFunc(t, func(tTile *Tile) bool {
				return tile == *tTile
			})
			if isInTrail {
				out.WriteString(strconv.Itoa(tile.Height))
			} else {
				out.WriteRune('.')
			}
		}
		out.WriteRune('\n')
	}

	return out.String()
}

func main() {
	hikeMap := parseMap()
	trails := findTrails(hikeMap)
	trailScores, _ := scoreTrailheads(trails)

	// for _, trail := range trails {
	// 	fmt.Println(trail.MapString(hikeMap))
	// }

	// for head, score := range trailScores {
	// 	fmt.Printf("head:%v | score:%d\n", head, score)
	// }

	part1 := 0
	for _, score := range trailScores {
		part1 += score
	}

	fmt.Printf("Part 1: %d\n", part1)
	fmt.Printf("Part 2: %d\n", len(trails))
}

func parseMap() Map {
	inputBytes, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	input := string(inputBytes)
	lines := strings.Split(input, "\n")
	result := make(Map, len(lines))

	for row, inputLine := range lines {
		line := make([]Tile, len(inputLine))
		for column, ch := range inputLine {
			value := -1

			if ch != '.' { // Support debug inputs
				value, err = strconv.Atoi(string(ch))
				if err != nil {
					panic(err)
				}
			}

			line[column] = Tile{
				Height: value,
				Row:    row,
				Column: column,
			}
		}
		result[row] = line
	}

	return result
}

func findTrails(hikeMap Map) []Trail {
	// Find how many start points there are
	starts := []*Tile{}

	for _, row := range hikeMap {
		for x, tile := range row {
			if tile.Height == 0 {
				starts = append(starts, &row[x])
			}
		}
	}

	// Calculate results
	trails := []Trail{}

	for _, start := range starts {
		var explore func(Trail)
		explore = func(trail Trail) {
			previous := trail[len(trail)-1]
			toCheck := []*Tile{}

			if previous.Height == 9 {
				trails = append(trails, slices.Clone(trail))
				return
			}

			if previous.Row > 0 {
				toCheck = append(toCheck, &hikeMap[previous.Row-1][previous.Column])
			}
			if previous.Column > 0 {
				toCheck = append(toCheck, &hikeMap[previous.Row][previous.Column-1])
			}
			if previous.Row < len(hikeMap)-1 {
				toCheck = append(toCheck, &hikeMap[previous.Row+1][previous.Column])
			}
			if previous.Column < len(hikeMap[0])-1 {
				toCheck = append(toCheck, &hikeMap[previous.Row][previous.Column+1])
			}

			for _, tile := range toCheck {
				if tile.Height != previous.Height+1 {
					continue
				}
				explore(append(trail, tile))
			}
		}

		explore(Trail{start})
	}

	return trails
}

func scoreTrailheads(trails []Trail) (map[*Tile]int, []Trail) {
	scores := make(map[*Tile]int)
	endsForHead := make(map[*Tile][]*Tile)
	selectedTrails := []Trail{}

	for _, trail := range trails {
		head := trail[0]
		end := trail[len(trail)-1]

		if ends, ok := endsForHead[head]; ok {
			if slices.Contains(ends, end) {
				continue
			}
			endsForHead[head] = append(endsForHead[head], end)
		} else {
			endsForHead[head] = []*Tile{end}
		}

		scores[head] += 1
		selectedTrails = append(selectedTrails, trail)
	}

	return scores, selectedTrails
}
