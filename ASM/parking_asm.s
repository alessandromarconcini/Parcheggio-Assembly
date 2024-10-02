.section .data

### STRINGHE DI ERRORE ###

str_settore: .ascii "Errore nell'inizializzazione di uno dei settori! Rivedi il file di testo\n"  # Stringa di errore per i settori
str_settore_len: .long .-str_settore  #Lunghezza della stringa str_settore 

### ALTRI VALORI ###

NPOSTIA: .long 0
NPOSTIB: .long 0
NPOSTIC: .long 0
valori_inseriti: .long 0 # Tiene conto se tutti e 3 i valori sono stati inseriti
SBARRE:  .long 0
LIGHTS: .long 0
ecx_tmp: .long 0
cont: .long 0

######################################

.section .text

    .global parking_asm
    
parking_asm:

    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %esi  #bufferin
    movl 12(%ebp) ,%edi #bufferout_asm
    
    movl $0,%ecx
    movl $0, %eax
    movl $0, %ebx
    movl $0, %edx
    
leggi:
    
    movb (%ecx,%esi,1), %bl
    
    cmp $65, %bl
    je prima_lettura
    cmp $66, %bl
    je prima_lettura
    cmp $67, %bl
    je prima_lettura
    
    inc %ecx
    jmp leggi
    
prima_lettura:
    
    call leggi_lettera # Questa funzione legge lettera+trattino della stringa e poi mette il risultato in eax
    
    inc %ecx #Salto il trattino
    
    pushl %eax # 2 PUSH <--- metto eax sullo stack per utilizzarla dopo, prima necessito di un valore numerico
    
    call leggi_valore # Questa funzione legge ogni cifra numerica fino ad arrivare al carattere "\n" 
                      # Il valore di ritorno è in eax
    
    # Eseguo il check di che lettera si tratta #
    
    popl %ebx # Ritorno a 1 PUSH eseguiti (rimane solo ebp che abbiamo salvato sullo stack)
    
    cmp $65, %ebx
    je assegnamento_A
    cmp $66, %ebx
    je assegnamento_B
    cmp $67, %ebx
    je assegnamento_C
    
    jmp errore_inserimento_settori
    
assegnamento_A:
    
    cmp $31, %eax #Check se il settore può ospitare il numero di auto inserite
    jg assegnamento_max_A
    
    movl %eax,(NPOSTIA)
    movl (valori_inseriti), %ebx
    addl $100, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento
    
assegnamento_max_A:

    movl $31, (NPOSTIA)
    movl (valori_inseriti), %ebx
    addl $100, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento

assegnamento_B:
    
    cmp $31, %eax #Check se il settore può ospitare il numero di auto inserite
    jg assegnamento_max_B
    
    movl %eax,(NPOSTIB)
    movl (valori_inseriti), %ebx
    addl $10, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento
    
assegnamento_max_B:

    movl $31, (NPOSTIB)
    movl (valori_inseriti), %ebx
    addl $10, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento
    
assegnamento_C:
    
    cmp $24, %eax #Check se il settore può ospitare il numero di auto inserite
    jg assegnamento_max_C
    
    movl %eax,(NPOSTIC)
    movl (valori_inseriti), %ebx
    addl $1, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento
    
assegnamento_max_C:

    movl $24, (NPOSTIC)
    movl (valori_inseriti), %ebx
    addl $1, %ebx
    movl %ebx, (valori_inseriti)
    jmp post_assegnamento
    
post_assegnamento:
    
    movl (valori_inseriti), %ebx
    cmp $111, %ebx
    
    je fine_inserimenti #Ho inserito tutti e 3 i valori dei registri
    
    jmp prima_lettura # Ricomincio a leggere da capo il prossimo valore
    
fine_inserimenti:

    # Arrivato qui mi devo iniziare a comportare in modo diverso poichè inizia il funzionamento autonomo #
    
    movb (%esi,%ecx,1), %bl
    incl %ecx
    
    cmpb $73, %bl  # se è I
    je i
    
    cmpb $79, %bl # se è O
    je o
    
    jmp errore_entrata_uscita
    
i:
    movb (%esi,%ecx,1), %bl # Prelevo una ipotetica N
    incl %ecx
    
    cmpb $78, %bl # se è IN
    je in
    
    jmp errore_entrata_uscita
    
in:
    incl %ecx # Salto il trattino

    movb (%esi,%ecx,1), %bl # Prelevo la lettera del settore da incrementare
    incl %ecx
    
    cmpb $65, %bl
    je in_A
    
    cmpb $66, %bl
    je in_B
    
    cmpb $67, %bl
    je in_C
    
    jmp errore_entrata_uscita
    
in_A:

    movl (NPOSTIA), %eax
    incl %eax
    incl %ecx # voglio saltare il \n
    
    cmp $31, %eax
    jg A_pieno
    
    je A_diventa_pieno
    
    movl %eax, (NPOSTIA)
    movb $12, (SBARRE) #OC
    jmp stampa
    
A_pieno:

    movl $31, %eax
    movl %eax,(NPOSTIA)
    movb $22, (SBARRE) #CC
    jmp stampa
    
A_diventa_pieno:

    movl %eax,(NPOSTIA)
    movb $12, (SBARRE) #OC
    jmp stampa
    
in_B:

    movl (NPOSTIB) ,%eax
    incl %eax
    incl %ecx # voglio saltare il \n
    
    cmp $31, %eax
    jg B_pieno
    
    je B_diventa_pieno
    
    movl %eax, (NPOSTIB)
    movb $12, (SBARRE) #OC
    jmp stampa
    
B_pieno:

    movl $31, %eax
    movl %eax,(NPOSTIB)
    movb $22, (SBARRE) #CC 
 
    jmp stampa
    
B_diventa_pieno:

    movl %eax,(NPOSTIB)
    movb $12, (SBARRE) #OC
    jmp stampa
    
in_C:

    movl (NPOSTIC) ,%eax
    incl %eax
    incl %ecx # voglio saltare il \n
    
    cmp $24, %eax
    jg C_pieno
    
    je C_diventa_pieno
    
    movl %eax, (NPOSTIC)
    movb $12, (SBARRE) #OC
    jmp stampa
    
C_pieno:

    movl $24, %eax
    movl %eax,(NPOSTIC)
    movb $22, (SBARRE) # Metto closed alle sbarre in entrata ("C")
    jmp stampa
    
C_diventa_pieno:

    movl %eax,(NPOSTIC)
    movb $12, (SBARRE) #OC
    jmp stampa
    
o:  

    movb (%esi,%ecx,1), %bl # ipotetico U
    incl %ecx
    cmpb $85, %bl
    je ou
    
    jmp errore_entrata_uscita
    
ou:
    movb (%esi,%ecx,1), %bl # ipotetico T
    incl %ecx
    cmpb $84, %bl
    je out
    
    jmp errore_entrata_uscita
    
out:
    
    incl %ecx # Salto il trattino
    
    movb (%esi,%ecx,1), %bl # mi aspetto A,B o C
    incl %ecx
    
    cmpb $65, %bl
    je out_A
    
    cmpb $66, %bl
    je out_B
    
    cmpb $67, %bl
    je out_C
    
    jmp errore_entrata_uscita
    
out_A:

    movl (NPOSTIA), %eax
    incl %ecx # Salto il carattere \n
    
    cmp $0, %eax # Se il settore è vuoto non avviene il decremento
    je not_out_A
    
    subl $1, %eax
    movl %eax ,(NPOSTIA)
    movb $21, (SBARRE) # CO
    jmp stampa
    
not_out_A:

    movb $22, (SBARRE) #CC
    movl %eax, (NPOSTIA)
    jmp stampa

out_B:

    movl (NPOSTIB), %eax
    incl %ecx # Salto il carattere \n
    
    cmp $0, %eax # Se il settore è vuoto non avviene il decremento
    je not_out_B
    
    subl $1, %eax
    movl %eax ,(NPOSTIB)
    movb $21,(SBARRE) #CO
    jmp stampa
    
not_out_B:

    movb $22, (SBARRE) #CC
    movl %eax, (NPOSTIB)
    jmp stampa
    
out_C:

    movl (NPOSTIC), %eax
    incl %ecx # Salto il carattere \n
    
    cmp $0, %eax # Se il settore è vuoto non avviene il decremento
    je not_out_C
    
    subl $1, %eax
    movl %eax ,(NPOSTIC)
    movb $21, (SBARRE) # CO
    jmp stampa
    
not_out_C:

    movb $22, (SBARRE) # CC
    movl %eax, (NPOSTIC)
    jmp stampa

errore_entrata_uscita:

    movb $22, (SBARRE) #CC
    
    cmpb $10, %bl
    je fine_scorrimento_errore

    incl %ecx
    movb (%esi,%ecx,1), %bl
    jmp errore_entrata_uscita
    
fine_scorrimento_errore:

    incl %ecx
    jmp stampa
    
    
stampa:

    cmpb $0 ,%bl
    
    je ultima_stampa
    
    jmp stampa_pt1
    
ultima_stampa:

    addl $1,(cont)
    jmp stampa_pt1
    
stampa_pt1:

    # Valori di LIGHTS #
    
    movl $0, (LIGHTS)
    movl (NPOSTIA), %eax
    
    cmp $31, %eax
    
    jge add_100
    
not_add_100:

    movl (NPOSTIB), %eax
    
    cmp $31, %eax
    
    jge add_10
    
not_add_10:

    movl (NPOSTIC), %eax
    
    cmp $24, %eax
    
    jge add_10
    
    jmp inizia_stampa
    
add_100:
    
    addl $100, (LIGHTS)
    jmp not_add_100
    
add_10:

    addl $10, (LIGHTS)
    jmp not_add_10
    
add_1:

    addl $1,(LIGHTS)
    jmp inizia_stampa

inizia_stampa:

    pushl %ecx # Metto momentaneamente il contatore di bufferin sullo stack
    
    movl (ecx_tmp), %ecx
    
    # Considero bufferout_asm che si trova in edi #
    
    # SBARRE # 
    
    movl (SBARRE), %eax
    
    cmp $11, %eax
    je oo
    cmp $12 ,%eax
    je oc
    cmp $21, %eax
    je co
    cmp $22, %eax
    je cc
    jmp errore_entrata_uscita
    
oo:
    movl $79, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
    jmp dopo_SBARRE
    
oc:

    movl $79, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    movl $67, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
    jmp dopo_SBARRE
    
co:

    movl $67, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    movl $79, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
    jmp dopo_SBARRE
    
cc:

    movl $67, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    movl $67, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
    jmp dopo_SBARRE
    
dopo_SBARRE:

    # Metto il trattino #

    movl $45, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
NPOSTI_:

    movl (NPOSTIA) ,%eax
    call num2str_NPOSTI
    movl (NPOSTIB), %eax
    call num2str_NPOSTI
    movl (NPOSTIC), %eax
    call num2str_NPOSTI
    
LIGHTS_:

    movb $3, %dl
    call num2str_LIGHTS
    
fine_riga_bufferout_asm:
    
    movb $10, (%ecx,%edi,1) # <-- Carattere \n
    inc %ecx
    
    movl %ecx, (ecx_tmp)
    
    # Recupero i valori precedenti dallo stack per ricominciare
    
    popl %eax # Vecchio contatore
    
    # Controllo se esi punta a \n o a \0 #
    
    movb (%eax,%esi,1), %bl
    cmpb $0, %bl
    
    je fine_stringa
    
    movl %eax, %ecx
    jmp fine_inserimenti
    
fine_stringa:

    cmp $0,(cont)
    je stampa

    movl (ecx_tmp) ,%eax

    #Metto il carattere \0 a fine stringa di bufferout_asm #
    
    movb $0, (%eax,%edi,1)

    # Esco dalla funzione assembly per tornare al codice C #
    
    popl %ebp
    Ret
    
#### LEGGI LETTERA ####
    
.type leggi_lettera, @function

leggi_lettera:
    movl $0, %ebx
    
lettura_settore:

    movb (%esi,%ecx,1), %bl 
    # Faccio un doppio check #
    cmpb $65, %bl
    jge lettera
    
    # Altrimenti#
    jmp errore_inserimento_settori
    
errore_inserimento_settori:
    
    movl $4, %eax
    movl $1, %ebx
    leal str_settore, %ecx
    movl str_settore_len, %edx
    int $0x80
    
    movl $1, %eax
    movl $1, %ebx  # <--- EXIT_FAILURE
    int $0x80

lettera:

    movb %bl, %al
    
    cmpb $68,%al
    jl lettera_return
    
    jmp errore_inserimento_settori
    
lettera_return:

    incl %ecx
    Ret # Ritorno al main
    
#### LEGGI VALORE ####
    
.type leggi_valore, @function

leggi_valore:
    
    xorl %eax, %eax #Azzero eax
    xorl %ebx, %ebx
    movb (%ecx,%esi,1), %bl
    
    # Check se è un capo riga #
    incl %ecx
    
    cmpb $10, %bl  # Controllo sullo \n
    je fine_lettura_valore
    
    subl $48,%ebx
    
    # Check che sia un numero #
    
    cmpb $0 ,%bl  # Se è una cifra decimale è compresa tra 0 e 10 con 10 non compreso
    
    jge forse_numero
    jmp errore_inserimento_settori
    
forse_numero:

    cmpb $10, %bl
    
    jl numero
    jmp errore_inserimento_settori
    
numero:
    
    pushl %ebx # Metto la cifra sullo stack
    jmp leggi_valore
    
fine_lettura_valore:

    popl %ebx
    cmp $65,%ebx
    
    jl cifra
    
    #Altrimenti
    pushl %ebx
    Ret 
    
cifra:

    cmp $0,%al
    jne lascia_in_ebx
    
    movl %ebx ,%eax
    
    jmp fine_lettura_valore
    
    #Risultato in eax
    Ret
    
lascia_in_ebx: # Se sono qui significa che invece di una ho due cifre

    movl %ebx,%edx
    movl %eax,%ebx
    movl %edx, %eax
    
    movl $10, %edx
    mulb %dl
    
    addl %ebx, %eax
    
    jmp fine_lettura_valore
    
#######################

.type num2str_NPOSTI, @function

num2str_NPOSTI:
    
    movl $10 ,%ebx
    divb %bl
    movb %ah,%dl
    addb $48, %al
    addb $48,%dl
    movb %al, (%ecx,%edi,1)
    inc %ecx
    movb %dl, (%ecx,%edi,1)
    inc %ecx
    
    # Metto il trattino #

    movl $45, %ebx
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    
    Ret
    
####################################
    
.type num2str_LIGHTS, @function

num2str_LIGHTS:

    movl (LIGHTS), %eax

    cmp $0, %dl
    je fine_trasferimento

    movl $10 ,%ebx
    divb %bl
    movb %al,(LIGHTS)
    movb %ah ,%bl
    addb $48 ,%bl
    movb %bl, (%ecx,%edi,1)
    inc %ecx
    dec %edx
    
    jmp num2str_LIGHTS # Il loop si verifica per un totale di 4 volte (L'ultima solo per uscire)
    
fine_trasferimento:
    Ret

    
    
    
    
    
    
    
    
    
