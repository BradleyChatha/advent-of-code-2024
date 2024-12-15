.PHONY: run
run:
	yasm src/main.asm -f elf64 -o main.o -g dwarf2 && gcc main.o -o asm_output --no-pie && ./asm_output
	echo Done