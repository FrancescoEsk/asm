AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/mcd

bin/mcd: obj/mcd.o
	ld $(LD_FLAGS) obj/mcd.o -o bin/mcd


obj/mcd.o: src/mcd.s
	as $(AS_FLAGS) $(DEBUG) src/mcd.s -o obj/mcd.o


clean:
	rm -f obj/mcd.o bin/mcd