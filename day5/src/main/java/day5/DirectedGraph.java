package day5;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class DirectedGraph {
    private record Node(int value, List<Node> children) {}

    private HashMap<Integer, Node> _nodeByValue;

    public DirectedGraph() {
        this._nodeByValue = new HashMap<>();
    }

    private Node upsert(int value) {
        return this._nodeByValue.computeIfAbsent(value, v -> new Node(v, new ArrayList<>()));
    }

    public void addChild(int parent, int child) {
        this.upsert(parent).children.add(this.upsert(child));
    }

    // The input isn't acyclic, but it does seem to provide all permutations, rather than
    // requiring a full graph walk, so we only need to test direct children.
    //
    // I could've just used a map, but all the code was already written around this class before
    // I realised the input didn't require a DAG, so may as well make use of it even if it's wasted space now :D
    public boolean isDirectChild(int parent, int maybeChild) {
        for(var child : this.upsert(parent).children) {
            if(child.value == maybeChild)
                return true;
        }

        return false;
    }
}
