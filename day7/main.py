from itertools import product

class Equation:
    test: int
    numbers: list[int]
    isPart1: bool
    isPart2: bool

    def __init__(self, test: int, numbers: list[int]):
        self.test = test
        self.numbers = numbers
        self.isPart1 = False
        self.isPart2 = False

    def try_solution(self, operators: list[str], part: int):
        assert len(operators) == len(self.numbers) - 1, "Too many/too few operators"

        if len(operators) == 0:
            return

        acc = 0
        def do(acc: int, num1: int, operator: str, num2: int):
            match operator:
                case '+':
                    acc = num1 + num2
                case '*':
                    acc = num1 * num2
                case '|':
                    acc = int(str(num1) + str(num2))
                case _:
                    assert False
            return acc

        acc = do(acc, self.numbers[0], operators[0], self.numbers[1])
        for i in range(1, len(operators)):
            acc = do(acc, acc, operators[i], self.numbers[i+1])

        if acc == self.test:
            if part == 1:
                self.isPart1 = True
            else:
                self.isPart2 = True


equations: list[Equation] = []
with open("input.txt") as f:
    splitLines = [x.split(": ") for x in f.read().splitlines()]
    equations = [Equation(int(x[0]), [int(y) for y in x[1].split(" ")]) for x in splitLines]

for equation in equations:
    if len(equation.numbers) == 0:
        continue
    permutations = list(product("+*", repeat=len(equation.numbers)-1))
    permutations2 = list(product("+*|", repeat=len(equation.numbers)-1))
    
    for operators in permutations:
        equation.try_solution(operators, part=1)
    for operators in permutations2:
        equation.try_solution(operators, part=2)

print("Part 1:", sum([equation.test for equation in equations if equation.isPart1]))
print("Part 2:", sum([equation.test for equation in equations if equation.isPart2]))

# 1 _ 1
# 2 _ 2 _ 2
# 3 _ 3 _ 3 _ 3