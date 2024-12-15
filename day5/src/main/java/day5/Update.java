package day5;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public record Update(List<Integer> pages, int middle) {
    public static Update fromLine(String line){
        var list = Arrays
                    .stream(line.split(","))
                    .mapToInt(str -> Integer.parseInt(str))
                    .boxed()
                    .toList();
        return new Update(list, list.get(list.size()/2));
    }

    public boolean isRightOrder(DirectedGraph graph) {
        for(int i = 0; i < this.pages.size(); i++) {
            var iValue = this.pages.get(i);
            for(int j = i + 1; j < this.pages.size(); j++) {
                var jValue = this.pages.get(j);
                var jMustBeBeforeI = graph.isDirectChild(jValue, iValue);

                if(jMustBeBeforeI)
                    return false;
            }
        }
        return true;
    }

    public Update selfCorrect(DirectedGraph graph) {
        // Now THIS is where a DAG could actually be useful... but now I CBA to write the top sort xD
        // This is so bad and inefficient, but it's just advent of code.

        while(!this.isRightOrder(graph)) {
            for(int i = 0; i < this.pages.size(); i++) {
                var iValue = this.pages.get(i);
                for(int j = i + 1; j < this.pages.size(); j++) {
                    var jValue = this.pages.get(j);
                    var jMustBeBeforeI = graph.isDirectChild(jValue, iValue);

                    if(jMustBeBeforeI) {
                        var pages = new ArrayList<Integer>(this.pages);
                        pages.set(i, this.pages.get(j));
                        pages.set(j, this.pages.get(i));
                        return new Update(pages, pages.get(pages.size()/2)).selfCorrect(graph);
                    }
                }
            }
        }

        return this;
    }
}
