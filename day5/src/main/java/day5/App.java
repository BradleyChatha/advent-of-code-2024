package day5;

import java.io.IOException;
import java.nio.file.Path;

/**
 * Hello world!
 */
public class App {
    public static void main(String[] args) throws IOException {
        var input = Input.fromFile(Path.of("input.txt"));
        var graph = new DirectedGraph();

        for (var rule : input.rules()) {
            graph.addChild(rule.page(), rule.constraintPage());
        }

        int part1 = 0;
        int part2 = 0;
        for (var update : input.updates()) {
            if(update.isRightOrder(graph)) {
                part1 += update.middle();
            } 
            else {
                part2 += update.selfCorrect(graph).middle();
            }
        }

        System.out.printf("Part 1: %d\n", part1);
        System.out.printf("Part 2: %d\n", part2);
    }
}
