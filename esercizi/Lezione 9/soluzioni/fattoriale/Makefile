AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386


all: bin/fattoriale

bin/fattoriale: obj/fattoriale.o
	ld $(LD_FLAGS) obj/fattoriale.o -o bin/fattoriale


obj/fattoriale.o: src/fattoriale.s
	as $(AS_FLAGS) $(DEBUG) src/fattoriale.s -o obj/fattoriale.o


clean:
	rm -f obj/fattoriale.o bin/fattoriale