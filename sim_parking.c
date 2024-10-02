#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>

// itoa
void itoa(int num,char * str_tmp);

int main(int argc,char * argv){
    
    int ligths = 0; // Luci accese se settore pieno
    char str[1024]; // IN/OUT + \0 (Carattere di fine stringa)
    int n_a = 0;
    int n_b = 0; // Numero posti di a,b,c
    int n_c = 0;
    char sbarre[3] = "OO" ; // OO/OC/CC/CO + \0 (Carattere di fine stringa)
    char sel = 'D'; // char buffer della selezione del settore del parcheggio
    char val[3] = "00";
    bool in_out = 0;
    bool day_or_night = 0; // 0 giorno 1 notte
    char score = '-'; // Il trattino da stampare
    char a_capo = '\n'; //A capo
    
    // File aperti
    int fd = open("testin.txt",O_RDONLY,S_IRUSR | S_IWUSR | S_IXUSR);
    int fdout = open("testout.txt",O_WRONLY | O_CREAT,S_IRUSR | S_IWUSR | S_IXUSR);
    
    // Lettura da file dei settori
    
    if(day_or_night == 1){ // NOTE notte
     
        //Tutto aperto
        
        sbarre[0] = 'O'; //Aggiorno sbarre
        sbarre[1] = 'O';
        //sbarre[2] = '\0' già di base
        
        n_a = 0;
        n_b = 0; // Svuoto settori
        n_c = 0;
    }
    
    else { // NOTE giorno 
    
        for(int i = 0;i < 3;i++) { // Inseriamo 3 volte i valori di a,b,c alla partenza (NOTE non necessariamente nell'ordine indicato)
        
            read(fd,&sel,sizeof(sel));
            printf("%c",sel);
            lseek(fd,1,SEEK_CUR); //Sposto il cursore di 1, salto il trattino
            read(fd,&val,sizeof(char) * 2);
            
            if(sel == 'A')
                n_a = atoi(&val);
            else if(sel == 'B')
                n_b = atoi(&val);
            else if(sel == 'C')
                n_c = atoi(&val);
            else 
                printf("Anomalia, il file testin.txt non è scritto correttamente!\n");
        }
        
        // Check sui dati
        
        if(n_a > 31)
            n_a = 31;
        if(n_b > 31)
            n_b = 31;
        if(n_c > 24)
            n_c = 24;
        
        // Lettura delle entrare/uscite
        
        int bR = read(fd,&str,sizeof(str));
        
        if(bR == -1) { // Check sul numero di byte letti sequenzialmente ( se è -1 la funz da errore)
            printf("Errore nella lettura della stringa entrata/uscita\n");
            exit(1);
        }
        
        int j = 0;
        
        if(str[j] == 'I') {
            j = j+2; // Memorizzo IN e vado avanti fino a "-"
            in_out = 0; // In entrata
        }
        if(str[j] == 'O') {
            j = j+3; // Memorizzo OUT e vado avanti fino a "-"
            in_out = 1; // In uscita
        }
            
        j++; // salto il valore "-"
        
        // ENTRATA
        
        if(in_out == 0){
        
            if(str[j] == 'A' || str[j] == 'a'){
            
                if(n_a == 31) {
                    sbarre[0] = 'C'; // Le sbarre in entrata sono chiuse
                    ligths += 100;
                }
                
                else {
                    n_a++;
                    sbarre[0] = 'O'; // Le sbarre in entrata sono aperte per disponibilità di posto
                }
            }
            
            if(str[j] == 'B' || str[j] == 'b'){
            
                if(n_b == 31) {
                    sbarre[0] = 'C'; // Le sbarre in entrata sono chiuse
                    ligths += 10;
                }
                
                else {
                    n_b++;
                    sbarre[0] = 'O'; // Le sbarre in entrata sono aperte per disponibilità di posto
                }
            }
            
            if(str[j] == 'C' || str[j] == 'c'){
            
                if(n_c == 24){
                    sbarre[0] = 'C'; // Le sbarre in entrata sono chiuse
                    ligths += 1;
                }
                
                else {
                    n_c++;
                    sbarre[0] = 'O'; // Le sbarre in entrata sono aperte per disponibilità di posto
                }
            }
        }
        
        // CHIUSURA
        
        if(in_out == 1){
        
            if(str[j] == 'A' || str[j] == 'a'){
            
                if(n_a == 0)
                    printf("Errore il settore A è vuoto\n");
                
                else {
                    n_a--;
                    sbarre[1] = 'O'; // Apriamo le sbarre
                }
            }
            
            if(str[j] == 'B' || str[j] == 'b'){
            
                if(n_b == 0)
                    printf("Errore il settore B è vuoto\n");
                
                else {
                    n_b--;
                    sbarre[1] = 'O'; // Apriamo le sbarre
                }
            }
            
            if(str[j] == 'C' || str[j] == 'c'){
            
                if(n_c == 0)
                    printf("Errore il settore C è vuoto\n");

                
                else {
                    n_c--;
                    sbarre[1] = 'O'; // Apriamo le sbarre
                }
            }
        } // end CHIUSURA
    } // fine GIORNO
    
    // Stampa dei valori su testout.txt
        
        write(fdout, &sbarre[0],sizeof(char)); // Immetto il valore delle sbarre
        write(fdout, &sbarre[1],sizeof(char));
        write(fdout, &score,sizeof(score)); // Trattino
        
        char * str_a;
        itoa(n_a,str_a);
        
        printf("%s",str_a);
        
        char * str_b;
        itoa(n_b,str_b);
        
        printf("%s",str_b);
        
        char * str_c;
        itoa(n_c,str_c);
        
        printf("%s",str_c);
        
        write(fdout, &str_a,sizeof(str_a));
        write(fdout, &score,sizeof(score));
        
        write(fdout, &str_b,sizeof(str_b));
        write(fdout, &score,sizeof(score));
        
        write(fdout, &str_b,sizeof(str_b));
        write(fdout, &score,sizeof(score));
        
        char * str_ligths;
        itoa(&ligths,str_ligths);

        write(fdout,&str_ligths,sizeof(str_ligths));
        write(fdout,&a_capo,sizeof(a_capo));
        
        close(fd); // Chiudo testin.txt
        close(fdout); // Chiudo testout.txt
}

void itoa(int num,char * str_tmp){
    
    // Esempio 17
    
    int resto = 0;
    int i = 0;
    
    while(num > 0) {
    
    resto = num % 10; // Ottengo il 7 (prima cifra)
    str_tmp[i] = num + 48; // 48 è l' ascii per arrivare al carattere numerico
    num /= 10;
    i++;
    }

    i++;
    str_tmp[i] = '\0';
}
