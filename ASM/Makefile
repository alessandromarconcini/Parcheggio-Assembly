RM= rm -f
EXE= parking
GCCCO= gcc -m32 -c
GCCO= gcc -m32 -o

all:

	$(GCCCO) -ggdb -o parking.o parking.c
	$(GCCCO) -o parking_asm.o parking_asm.s
	$(GCCO) parking parking.o parking_asm.o

run:
	./parking
	
clean: 
	$(RM) parking.o
	$(RM) parking_asm.o
	$(RM) $(EXE)
