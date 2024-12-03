open System
open System.IO

type Pair = (int * int)

let args = Environment.GetCommandLineArgs()
let input = File.ReadAllText(args[1])

let linePairs = 
    input.Split('\n')
    |> Array.map (fun line -> line.Split("   "))

let leftNumbers = linePairs |> Array.map (fun pairs -> int pairs[0]) |> Array.sort
let rightNumbers = linePairs |> Array.map (fun pairs -> int pairs[1]) |> Array.sort
let pairs = Array.map2 (fun left right -> Pair(left, right)) leftNumbers rightNumbers

let distances = pairs |> Array.map (fun (left, right) -> abs (left - right))
printfn "Part 1: %d" (distances |> Array.sum)

let rightCounts = 
    pairs 
    |> Array.countBy (fun (_, right) -> right) 
    |> Map.ofArray
let leftScore =
    pairs
    |> Array.map (fun (left, _) ->
        match rightCounts.TryFind(left) with
        | Some score -> left * score
        | None -> 0
    )
    |> Array.sum
printfn "Part 2: %d" leftScore