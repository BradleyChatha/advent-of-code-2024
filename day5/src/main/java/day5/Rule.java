package day5;

import java.util.Arrays;

public record Rule(int page, int constraintPage) {
    public static Rule fromLine(String line) {
        var nums = Arrays
                        .stream(line.split("\\|"))
                        .mapToInt(str -> Integer.parseInt(str))
                        .toArray();
        return new Rule(nums[0], nums[1]);
    }
}
