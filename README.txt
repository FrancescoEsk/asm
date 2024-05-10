COME COMPILARE ED ESEGUIRE FILE ASSEMBLY

FILE: hello.s

as -o hello.o hello.s

ld -o hello hello.o
o
ld -o hello.x hello.o


COME DEBUGGARE FILE ASSEMBLY (GIA' ESEGUIBILI) (VEDI gdb.pdf)
gbd --> per entrare nella shell di degub 

file hello.x --> lo carico

break <file_sorgente.s>:<numero_riga> --> imposta un breakpoint alla riga specificata 

list  --> (con file caricato) stampa le righe del file caricato

run --> esegue il file (fino al breakpoint se impostato)

info register --> stampa il contenuto dei registri quando il programma è sospeso su un’istruzione 

p/formato %registro 
--> 
Stampa il contenuto del registro “registro”  nel  formato  indicato 
dall’opzione  “formato”.  Le  possibili opzioni  sono:  x  per  esadecimale,  o  per ottale, d per decimale, t per binario

x/nb &indirizzo
--> 
Visualizza  il  contenuto  di n  byte  della memoria  a  partire  della  locazione  di  cui 
viene fornito l’indirizzo. L'indirizzo può essere  rappresentato  dal  nome  di  una variabile.

step --> esegue la prossima istruzione mentre il programma e' sospeso

next --> come step, ma se si deve eseguire una istruzione, essa viene eseguita tutta in una singola next

continue --> vai fino al prossimo break

finish --> continua l'esecuzione fino alla fine del programma
