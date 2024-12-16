#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#define bool char
#define true 1
#define false 0

typedef struct Coord
{
    int x;
    int y;
} Coord;

typedef struct String
{
    char* ptr;
    size_t length;
} String;

typedef struct Tile
{
    Coord coord;
    char frequency;
    bool hasPart1Antinode;
    bool hasPart2Antinode;
    struct Tile* next; // Linked List containing other tiles with the same frequency as this one.
} Tile;

typedef struct TileMap
{
    Tile** rowThenColumn;
    Tile* frequencyHeadNodes; // Array of nodes where each node is the head node of a frequency list
    size_t rows;
    size_t columns;
    size_t frequencies;
} TileMap;

String loadInput()
{
    String str;

    FILE* inputFile = fopen("input.txt", "r");
    if(!inputFile)
        exit(1);

    fseek(inputFile, 0, SEEK_END);
    str.length = ftell(inputFile);
    fseek(inputFile, 0, SEEK_SET);

    str.ptr = malloc(str.length+1);
    if(!str.ptr)
        exit(1);

    fread(str.ptr, 1, str.length, inputFile);
    fclose(inputFile);
    str.ptr[str.length] = 0;

    return str;
}

TileMap parseInput(String input)
{
    TileMap map = {};

    // Scan line length ahead of time to simplify some stuff.
    size_t lineLength = 0;
    while(input.ptr[lineLength] != '\n')
        lineLength++;
    map.columns = lineLength;

    // Similarly scan lines ahead of time
    size_t lineCursor = 0;
    size_t lineCount = 0;
    while(lineCursor < input.length)
        lineCount += input.ptr[lineCursor++] == '\n';
    if(input.ptr[input.length-1] != '\n') // If there's no ending new line, still account for the final line.
        lineCount++;
    map.rows = lineCount;
    map.rowThenColumn = (Tile**)calloc(map.rows, sizeof(Tile*));

    // Scan tiles.
    size_t rowCount = 0;
    size_t cursor = 0;
    while(cursor < input.length)
    {
        Tile* tiles = (Tile*)calloc(lineLength, sizeof(Tile));
        for(size_t i = 0; i < lineLength; i++, cursor++)
        {
            tiles[i].coord.x = i;
            tiles[i].coord.y = rowCount;
            tiles[i].frequency = input.ptr[cursor];
        }
        map.rowThenColumn[rowCount++] = tiles;
        cursor++; // Skip new line.
    }

    // Link tiles with the same frequency together (excluding '.')
    for(size_t y = 0; y < map.rows; y++)
    {
        for(size_t x = 0; x < map.columns; x++)
        {
            Tile* tile = &map.rowThenColumn[y][x];
            if(tile->frequency == '.' || tile->next)
                continue;

            map.frequencies++;
            map.frequencyHeadNodes = realloc(map.frequencyHeadNodes, sizeof(Tile) * map.frequencies); // bad
            map.frequencyHeadNodes[map.frequencies-1].frequency = tile->frequency;
            map.frequencyHeadNodes[map.frequencies-1].next = tile;

            for(size_t y2 = y; y2 < map.rows; y2++)
            {
                for(size_t x2 = 0; x2 < map.columns; x2++)
                {
                    if(y2 == y && x2 <= x)
                        continue;

                    Tile* tile2 = &map.rowThenColumn[y2][x2];
                    if(tile2->frequency == tile->frequency)
                    {
                        tile->next = tile2;
                        tile = tile2;
                    }
                }
            }
        }
    }

    return map;
}

bool tryPlace(TileMap map, Coord coord, bool part1, bool part2)
{
    printf(
        "  (%d, %d) %c %c ",
        coord.x, coord.y,
        part1, part2
    );

    if(
        (coord.x >= 0 && coord.x < map.columns)
        && (coord.y >= 0 && coord.y < map.rows)
    )
    {
        Tile* tile = &map.rowThenColumn[coord.y][coord.x];
        tile->hasPart1Antinode = tile->hasPart1Antinode || part1;
        tile->hasPart2Antinode = tile->hasPart2Antinode || part2;
        printf("true\n");
        return true;
    }

    printf("false\n");
    return false;
}

void placeAntiNodes(TileMap map)
{
    for(size_t headNodeIndex = 0; headNodeIndex < map.frequencies; headNodeIndex++)
    {
        Tile* node = map.frequencyHeadNodes[headNodeIndex].next;
        while(node)
        {
            Tile* other = node->next;
            node->hasPart2Antinode = true;
            while(other)
            {
                other->hasPart2Antinode = true;
                Coord distance = {
                    other->coord.x - node->coord.x,
                    other->coord.y - node->coord.y
                };

                Coord nodeAnti = node->coord;
                nodeAnti.x -= distance.x;
                nodeAnti.y -= distance.y;

                Coord otherAnti = other->coord;
                otherAnti.x += distance.x;
                otherAnti.y += distance.y;

                printf(
                    "n:(%d, %d) - o:(%d, %d) -> d:(%d, %d)\n",
                    node->coord.x, node->coord.y,
                    other->coord.x, other->coord.y,
                    distance.x, distance.y
                );

                tryPlace(map, nodeAnti, true, true);
                tryPlace(map, otherAnti, true, true);

                while(tryPlace(map, nodeAnti, false, true))
                {
                    nodeAnti.x -= distance.x;
                    nodeAnti.y -= distance.y;
                }

                while(tryPlace(map, otherAnti, false, true))
                {
                    otherAnti.x += distance.x;
                    otherAnti.y += distance.y;
                }

                other = other->next;
            }
            node = node->next;
        }
    }
}

void printMap(TileMap map)
{
    for(size_t y = 0; y < map.rows; y++)
    {
        for(size_t x = 0; x < map.columns; x++)
        {
            Tile tile = map.rowThenColumn[y][x];

            if(tile.hasPart1Antinode || tile.hasPart2Antinode)
            {
                if(tile.frequency != '.')
                    putchar('@');
                else
                    putchar('#');
            }
            else
                putchar(tile.frequency);
        }
        putchar('\n');
    }
}

void countActiveTiles(TileMap map, int *part1, int *part2)
{
    int result1 = 0;
    int result2 = 0;

    for(size_t y = 0; y < map.rows; y++)
    {
        for(size_t x = 0; x < map.columns; x++)
        {
            result1 += map.rowThenColumn[y][x].hasPart1Antinode;
            result2 += map.rowThenColumn[y][x].hasPart2Antinode;
        }
    }

    *part1 = result1;
    *part2 = result2;
}

int main()
{
    String input = loadInput();
    TileMap map = parseInput(input);
    placeAntiNodes(map);
    printMap(map);

    int part1, part2;
    countActiveTiles(map, &part1, &part2);

    printf("Part 1: %d\n", part1);
    printf("Part 2: %d\n", part2);

    return 0;
}