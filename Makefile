all:
	nasm tictactoe.asm -o tictactoe.obj -f elf64
	ld tictactoe.obj -o tictactoe.exe
	rm tictactoe.obj
	./tictactoe.exe
	rm tictactoe.exe
compile:
	nasm tictactoe.asm -o tictactoe.obj -f elf64
link:
	ld tictactoe.obj -o tictactoe.exe
run:
	./tictactoe.exe