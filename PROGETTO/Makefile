# file per creare una toolchain di compilazione

EXE= bin/menu.x # nome del file eseguibile che si vuole creare

# variabile per specificare i compilatori da usare
AS= as --32 # compilatore di assembly a 32 bit
LD= ld -m elf_i386 # linker di assembly
FLAGS= -gstabs # parametri che vengono passati al compilatore per certi comportamenti
# in questo caso, abilitiamo il tool di debug

OBJ= obj/menu.o obj/scanfd.o obj/printfd.o # dichiaro file oggetto

# il mio target e' l'eseguibile
# $(..) indica il valore della variabile
# : --> dipende
$(EXE):  $(OBJ) # perche' esista l'exe deve esistere il file oggetto
	$(LD) -o $(EXE) $(OBJ) 

obj/menu.o: src/menu.s
	$(AS) $(FLAGS) -o obj/menu.o src/menu.s

obj/scanfd.o: src/scanfd.s
	$(AS) $(FLAGS) -o obj/scanfd.o src/scanfd.s

obj/printfd.o: src/printfd.s
	$(AS) $(FLAGS) -o obj/printfd.o src/printfd.s

clean:
	rm -f *.o $(EXE) core

r: 
	./$(EXE)

# VADO NELLA CONSOLE
# ho fatto il mio file assembly
# make
# e compila

# make clean 
# ed elimina ciò che ha compilato

# se faccio due volte make di fila, mi avvisa che il file .x da creare è già aggiornato 
# (controlla quando e' stato aggiornato il file, e se non ci sono aggiornamenti non compila di nuovo)
# (se invece lo modifico e rifaccio il make, lo aggiorna)
