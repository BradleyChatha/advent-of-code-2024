using Index = (int x, int y);

var input = File.ReadAllText("input.txt");
var charsPerLine = input.IndexOf('\n');
string[] matrix = input.Split('\n');

// This is so yucky lol
List<Index[]> calculateCompareList(int wordSize)
{
    List<List<Index>> interim = [[], [], [], [], [], [], [], []];

    for(int i = 1; i < wordSize; i++)
    {
        interim[0].Add((i, 0));     // >
        interim[1].Add((i, i));     // >v
        interim[2].Add((0, i));     // v
        interim[3].Add((-i, i));    // <v
        interim[4].Add((-i, 0));    // <
        interim[5].Add((-i, -i));   // <^
        interim[6].Add((0, -i));    // ^
        interim[7].Add((i, -i));    // >^
    }

    List<Index[]> result = [];
    foreach(var list in interim)
        result.Add([..list]);

    return result;
}

Index add(Index a, Index b) => (a.x + b.x, a.y + b.y);

bool isXmas(Index x, Index[] comparison)
{
    var m = add(x, comparison[0]);
    var a = add(x, comparison[1]);
    var s = add(x, comparison[2]);

    if(new Index[]{x, m, a, s}.Any(n => n.x < 0 || n.x >= charsPerLine || n.y < 0 || n.y >= matrix.Length))
        return false;

    return matrix[x.x][x.y] == 'X' && matrix[m.x][m.y] == 'M' && matrix[a.x][a.y] == 'A' && matrix[s.x][s.y] == 'S';
}

bool isX_Mas(Index a)
{
    if((a.x - 1) < 0 || (a.x + 1) >= charsPerLine || (a.y - 1) < 0 || (a.y + 1) >= matrix.Length)
        return false;
    if(matrix[a.y][a.x] != 'A')
        return false;

    var topLeft = matrix[a.y-1][a.x-1];
    var topRight = matrix[a.y-1][a.x+1];
    var botLeft = matrix[a.y+1][a.x-1];
    var botRight = matrix[a.y+1][a.x+1];
    
    var topLeftToBotRight = (
        ((topLeft == 'S') && (botRight == 'M'))
        || ((topLeft == 'M') && (botRight == 'S'))
    );
    var topRightToBotLeft = (
        ((topRight == 'S') && (botLeft == 'M'))
        || ((topRight == 'M') && (botLeft == 'S'))
    );

    return topLeftToBotRight && topRightToBotLeft;
}

var xmasCompare = calculateCompareList(4);

int xmasCount = 0;
int x_masCount = 0;
Index index = (0, 0);
for(int i = 0; i < input.Length; i++)
{
    index.x++;
    if(index.x > charsPerLine)
        index = (0, index.y + 1);

    foreach(var comparison in xmasCompare)
        xmasCount += isXmas(index, comparison) ? 1 : 0;
    x_masCount += isX_Mas(index) ? 1 : 0;
}

Console.WriteLine("Part 1: {0}", xmasCount);
Console.WriteLine("Part 2: {0}", x_masCount);