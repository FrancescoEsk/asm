# file per creare una toolchain di compilazione

EXE= bin/main.x # nome del file eseguibile che si vuole creare

# variabile per specificare i compilatori da usare
AS= as --32 # compilatore di assembly a 32 bit
LD= ld -m elf_i386 # linker di assembly
FLAGS= -gstabs # parametri che vengono passati al compilatore per certi comportamenti
# in questo caso, abilitiamo il tool di debug

OBJ= obj/convert.o obj/edf.o obj/hpf.o obj/main.o obj/printfd.o obj/printvideo.o obj/readl.o obj/revert.o obj/scanfd.o # dichiaro file oggetto

# il mio target e' l'eseguibile
# $(..) indica il valore della variabile
# : --> dipende
$(EXE):  $(OBJ) # perche' esista l'exe deve esistere il file oggetto
	$(LD) -o $(EXE) $(OBJ) 

obj/convert.o: src/convert.s
	$(AS) $(FLAGS) -o obj/convert.o src/convert.s

obj/edf.o: src/edf.s
	$(AS) $(FLAGS) -o obj/edf.o src/edf.s

obj/hpf.o: src/hpf.s
	$(AS) $(FLAGS) -o obj/hpf.o src/hpf.s

obj/main.o: src/main.s
	$(AS) $(FLAGS) -o obj/main.o src/main.s

obj/printfd.o: src/printfd.s
	$(AS) $(FLAGS) -o obj/printfd.o src/printfd.s

obj/printvideo.o: src/printvideo.s
	$(AS) $(FLAGS) -o obj/printvideo.o src/printvideo.s

obj/readl.o: src/readl.s
	$(AS) $(FLAGS) -o obj/readl.o src/readl.s

obj/revert.o: src/revert.s
	$(AS) $(FLAGS) -o obj/revert.o src/revert.s

obj/scanfd.o: src/scanfd.s
	$(AS) $(FLAGS) -o obj/scanfd.o src/scanfd.s

clean:
	rm -f $(EXE) core
	rm -f obj/*.o

# VADO NELLA CONSOLE
# ho fatto il mio file assembly
# make
# e compila

# make clean 
# ed elimina ciò che ha compilato

# se faccio due volte make di fila, mi avvisa che il file .x da creare è già aggiornato 
# (controlla quando e' stato aggiornato il file, e se non ci sono aggiornamenti non compila di nuovo)
# (se invece lo modifico e rifaccio il make, lo aggiorna)
