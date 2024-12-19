open System.IO
open System.Collections.Generic

let input = File.ReadAllText "input.txt"
let initStones = input.Split " " |> Array.map int

let rec digits (num: bigint) (_sum: int) =
    if num < (bigint 10) then
        _sum + 1
    else
        digits (num / (bigint 10)) (_sum + 1)

let halves (num: bigint) (numDigits: int) =
    let mutable numMut = num
    let mutable left = (bigint 0)
    let mutable right = (bigint 0)

    for digit = 1 to numDigits do
        if digit <= numDigits/2 then
            let multiplier = if digit = 1 then (bigint 1) else (pown (bigint 10) (digit - 1))
            right <- right + ((numMut % (bigint 10)) * multiplier)
        else
            let adjustedDigit = digit - (numDigits / 2)
            let multiplier = if adjustedDigit = 1 then (bigint 1) else (pown (bigint 10) (adjustedDigit - 1))
            left <- left + ((numMut % (bigint 10)) * multiplier)
        numMut <- numMut / (bigint 10)

    (left, right)

let cloneDict (dict : Dictionary<_, _>) =
    let result = Dictionary<_,_>()
    for iter in dict do
        result.Add(iter.Key, iter.Value)
    result

let seqDict (dict : Dictionary<_, _>) = seq {
    for iter in dict do
        yield (iter.Key, iter.Value)
}

let debugPrint (stones : Dictionary<int, int>) =
    let filtered = 
        seqDict stones 
        |> Seq.where (fun (_, count) -> count > 0)
        |> Seq.toList
        |> Seq.sortBy (fun (key, _) -> key)

    for (stone, count) in filtered do
        for i = 1 to count do
            printf "%d " stone
    printfn ""

let blink n =
    let mutable stoneMap = Dictionary<bigint, uint64>()

    for stone in initStones do
        if not (stoneMap.TryAdd(stone, 1UL)) then
            stoneMap[stone] <- stoneMap[stone] + 1UL

    for i = 1 to n do
        printfn "blink %d" i
        // debugPrint stoneMap
        let newStones = cloneDict stoneMap

        let incStone stone count =
            if not (newStones.TryAdd(stone, count)) then
                newStones[stone] <- newStones[stone] + count
    
        let decStone stone count =
            newStones[stone] <- newStones[stone] - count

        for iter in stoneMap do
            let stone = iter.Key
            let count = iter.Value

            if count > 0UL then
                let stoneDigits = digits stone 0

                decStone stone count
                match stoneDigits with
                | 1 when stone = (bigint 0) -> incStone (bigint 1) count
                | even when even % 2 = 0 -> 
                    let (left, right) = halves stone (int stoneDigits)
                    incStone left count
                    incStone right count
                | _ -> incStone (stone * (bigint 2024)) count

        stoneMap <- newStones
    stoneMap

let part1 = blink 25
let part2 = blink 75
// debugPrint part1
printfn "Part 1: %d" (seqDict part1 |> Seq.map (fun (_, value) -> value) |> Seq.sum)
printfn "Part 2: %A" (seqDict part2 |> Seq.map (fun (_, value) -> bigint value) |> Seq.sum)