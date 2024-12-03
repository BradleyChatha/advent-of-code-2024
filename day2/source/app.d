struct Report
{
    int[] levels;
    bool isSafe;
    bool isSortaSafe;
}

void main(string[] args)
{
    import std.algorithm : map, splitter, count;
    import std.array     : array;
    import std.conv      : to;
    import std.file      : readText;
    import std.math      : abs;
    import std.stdio     : writeln;
    import std.string    : lineSplitter;

    const input = readText(args[1]);
    auto reports = 
        input
        .lineSplitter()
        .map!((line) => Report(line.splitter(' ').map!(to!int).array))
        .array;

    // Find safety for part 1
    NextReport: foreach(ref report; reports)
    {
        bool shouldDescend = report.levels[0] > report.levels[1];
        foreach(i, level; report.levels)
        {
            if(i == 0)
                continue;

            const diff = report.levels[i-1] - report.levels[i];
            const descends = diff > 0;
            if((!descends && shouldDescend) || (descends && !shouldDescend))
                continue NextReport;
            else if(diff.abs < 1 || diff.abs > 3)
                continue NextReport;
        }
        report.isSafe = true;
    }

    // Find safety for part 2
    // Almost certainly a better way to do this, but it works, so meh.
    // One idea is to recursively call findSaftey only when we identify bad numbers,
    // rather than trying to ignore all of them.
    void findSafety(ref Report report, size_t ignoreIndex)
    {
        bool shouldDescend = (ignoreIndex == 0)
            ? report.levels[1] > report.levels[2]
            : (ignoreIndex == 1)
                ? report.levels[0] > report.levels[2]
                : report.levels[0] > report.levels[1];
        foreach(i, level; report.levels)
        {
            const curr = (i == ignoreIndex) ? i - 1 : i;
            const next = (i == ignoreIndex - 1) ? i + 2: i + 1;

            if(next >= report.levels.length || curr >= report.levels.length)
                continue;

            const diff                  = report.levels[curr] - report.levels[next];
            const descends              = diff > 0;
            const isExpectedDirection   = descends == shouldDescend;
            const isInBounds            = diff.abs >= 1 && diff.abs <= 3;
            if(!isExpectedDirection || !isInBounds)
                return;
        }
        report.isSortaSafe = true;
    }
    foreach(ref report; reports)
    {
        foreach(i; 0..report.levels.length)
            findSafety(report, i);
    }

    writeln("Part 1: ", reports.count!"a.isSafe"());
    writeln("Part 2: ", reports.count!"a.isSortaSafe"());
}