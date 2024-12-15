package day5;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;

public record Input(Iterable<Rule> rules, Iterable<Update> updates) {
    public static Input fromFile(Path filePath) throws IOException {
        var rules = new ArrayList<Rule>();
        var updates = new ArrayList<Update>();

        boolean readingRules = true;
        for (var line : Files.readAllLines(filePath)) {
            if(readingRules){
                if(line.length() == 0) {
                    readingRules = false;
                    continue;
                }
                rules.add(Rule.fromLine(line));
            }
            else {
                updates.add(Update.fromLine(line));
            }
        }
    
        return new Input(rules, updates);
    }
}
