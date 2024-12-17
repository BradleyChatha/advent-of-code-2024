struct Block
{
    int id;
    size_t length;
    bool isEmpty;
}

Block[] readInput()
{
    import std.algorithm : map, filter;
    import std.array 	 : array;
    import std.conv      : to;
    import std.file 	 : readText;
    import std.string    : lineSplitter;
    import std.range 	 : enumerate;

    const input = readText("input.txt");
    int id = 0;
    return input
            .enumerate
            .map!((iter){
                const i = iter[0];
                const digit = "" ~ cast(char)iter[1]; // Otherwise .to doesn't work as expected
                if(i % 2 == 0)
                    return Block(id++, digit.to!int, false);
                else
                    return Block(-1, digit.to!int, true);
            })
            .array
            .filter!(b => b.length > 0)
            .array;
}

Block[] refrag(const Block[] initBlocks)
{
    import std.array : insertInPlace;

    Block[] blocks = initBlocks.dup;
    for(size_t i = 0; i < blocks.length;)
    {
        scope iBlock = &blocks[i];
        if(!iBlock.isEmpty)
        {
            i++;
            continue;
        }
        
        bool onlyEmptyLeft = true;
        for(size_t j = blocks.length-1; j > i; j--) // @suppress(dscanner.suspicious.length_subtraction)
        {
            scope jBlock = &blocks[j];
            if(jBlock.isEmpty)
                continue;
            onlyEmptyLeft = false;

            if(iBlock.length > jBlock.length)
            {
                const oldJBlock = *jBlock;
                jBlock.isEmpty = true;
                jBlock.id = -1;
                iBlock.length -= jBlock.length;
                insertInPlace(blocks, i, Block(oldJBlock.id, oldJBlock.length, false));

                iBlock = &blocks[i + 1];
                // writeList(blocks);
                break;
            }
            else if(iBlock.length == jBlock.length)
            {
                const oldIBlock = *iBlock;
                *iBlock = *jBlock;
                *jBlock = oldIBlock;
                // writeList(blocks);
                break;
            }
            else
            {
                iBlock.isEmpty = false;
                iBlock.id = jBlock.id;
                jBlock.length -= iBlock.length;
                insertInPlace(blocks, j+1, Block(-1, iBlock.length, true));
                // writeList(blocks);
                break;
            }
        }

        if(onlyEmptyLeft)
            break;
    }

    return blocks;
}

Block[] defrag(const Block[] initBlocks)
{
    import std.array : insertInPlace;
    
    Block[] blocks = initBlocks.dup;

    for(size_t right = blocks.length-1; right > 0; right--) // @suppress(dscanner.suspicious.length_subtraction)
    {
        scope rightBlock = &blocks[right];
        if(rightBlock.isEmpty)
            continue;

        for(size_t left = 0; left < right; left++)
        {
            const oldRight = *rightBlock;
            scope leftBlock = &blocks[left];
            if(!leftBlock.isEmpty || leftBlock.length < rightBlock.length)
                continue;

            if(leftBlock.length == rightBlock.length)
            {
                blocks[right] = *leftBlock;
                blocks[left] = oldRight;
                break;
            }

            leftBlock.length -= rightBlock.length;
            rightBlock.isEmpty = true;
            rightBlock.id = -1;
            insertInPlace(blocks, left, oldRight);
            right++;
            break;
        }
    }

    return blocks;
}

void writeList(const Block[] blocks)
{
    import std.conv : to;
    import std.stdio : write, writeln;
    // writeln(blocks);

    foreach(block; blocks)
    {
        foreach(i; 0..block.length)
            write(block.isEmpty ? "." : block.id.to!string);
    }
    writeln();
}

ulong checksum(const Block[] blocks)
{
    import std.checkedint : Checked;
    
    Checked!ulong sum;

    int i = 0;
    foreach(block; blocks)
    {
        if(block.isEmpty)
        {
            i += block.length;
            continue;
        }

        foreach(_; 0..block.length)
        {
            sum += (block.id * i);
            i++;
        }
    }

    return sum.get;
}

void main()
{
    import std.stdio : writeln;

    const initBlocks = readInput();
    // writeList(initBlocks);
    
    const refragged = refrag(initBlocks);
    // writeList(refragged);

    const defragged = defrag(initBlocks);
    writeList(defragged);

    writeln("Part 1: ", checksum(refragged));
    writeln("Part 2: ", checksum(defragged));
}
