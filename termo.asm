;Termo em Assembly feito para materia SSC0221 - Introducao a Sistemas Computacionais
;
;Autores:
;	Francisco Maian nUSP: 14570890
;	Julia Pravato	nUSP:
;	Leticia Pravato	nUSP:
;

jmp main

Palavra: var #6			 ; Palavra a ser adivinhada
PalavraTentativa: var #6 ; Palavra chutada
NumTentativa: var #1	 ; Tentativa atual
Letra: var #1			 ; letra lida pelo teclado

; Mensagens que serao impressas na tela
Msn1:  string "Digite uma palavra de 5 letras:"
Msn2:  string "_____"
Msn3:  string "Letra verde:"
Msn4:  string " Letra certa na posicao certa"
Msn5:  string "Letra amarela:"
Msn6:  string " Letra certa na posicao errada"
Msn7:  string "Letra vermelha:"
Msn8:  string " Letra errada"
Msn9:  string "Voce Venceu! :)"
Msn10: string "Voce Perdeu! :/"
Msn11: string "Quer jogar novamente? <s/n>"

;---------- PROGRAMA PRINCIPAL ----------
main:
	; Inicializando e zerando as variaveis globais:
	loadn r0, #0
	store NumTentativa, r0	; Contador de Tentativas

	call inputPalavra ; Ler a palavra a ser adivinhada

	call chamaJogo
	
	;loop:
	;	call inputLetra
	;	call Compara
	;	call TestaFim
	;jmp loop

	halt ; finalizacao do termo

;Metodos:
;---------- LER PALAVRA ----------
inputPalavra:	; Le a palavra a ser adivinhada

	push fr ; protege o registrador de flags
	push r0 ; recebe a letra digitada
	push r1 ; contador de letras (vai ate 5)
	push r2 ; ponteiro para a palavra
	push r3 ; palavra[r2+r1]
	push r4 ; tamanho da palavra

	loadn r1, #0		; contador de quantidade de letras
	loadn r2, #Palavra	; ponteiro para palavra
	loadn r4, #5		; Tamanho da palavra

	call printPalavraMsn1	; Printa a Msn1

   inputPalavra_Loop:
		call digLetra		; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra				; Letra --> r0

		add r3, r2, r1
		storei r3, r0				; palavra[r2] = Letra

		inc r1
		cmp r1, r4						; verifica se o tamanho da palavra eh 5
		jne inputPalavra_Loop			; Se for, vai para o jogo
				
	;Coloca \0 no final da palavra
	loadn r0, #0
	add r3, r2, r1
	storei r3, r0				; palavra[r2] = /0

	pop r4
	pop r3
	pop r2
	pop r1
	pop r0	
	pop fr
	rts		
			
;---------- LER LETRA ----------
digLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push fr
	push r0
	push r1
	push r2
	loadn r1, #255	; Se nao digitar nada vem 255
	loadn r2, #0	; Logo que programa a FPGA o inchar vem 0

   digLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq digLetra_Loop	; Fica lendo ate' que digite uma tecla valida
		cmp r0, r2			;compara r0 com 0
		jeq digLetra_Loop	; Le novamente pois Logo que programa a FPGA o inchar vem 0

	store Letra, r0			; Salva a tecla na variavel global "Letra"
	
   digLetra_Loop2:	
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jne digLetra_Loop2	; Fica lendo ate' que digite uma tecla valida
	
	pop r2
	pop r1
	pop r0
	pop fr
	rts

;---------- SETA CONFIGURACOES PARA IMPRIMIR MSN1 ----------
printPalavraMsn1:
	push fr
	push r0
	push r1
	push r2
	
	loadn r0, #0		; Posicao na tela onde a mensagem sera escrita
	loadn r1, #Msn1		; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Seleciona a COR da Mensagem (Branco)
	call ImprimeStr
	
	pop r2
	pop r1
	pop r0	
	pop fr
	rts

;---------- IMPRIME STRING ----------
ImprimeStr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push fr	; Protege o registrador de flags
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3
		jeq ImprimeStr_Sai
		add r4, r2, r4
		outchar r4, r0
		inc r0
		inc r1
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts

; ---------- DESENHA O JOGO ----------
chamaJogo:
	push fr
	push r0
	push r1
	push r2

	call ApagaTela
	
	;print area primeira tentativa
	loadn r0, #18
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr
	
	;print area segunda tentativa
	loadn r0, #58
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr
	
	;print area terceira tentativa
	loadn r0, #98
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr

	;print area quarta tentativa
	loadn r0, #138
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr

	;print area quinta tentativa
	loadn r0, #178
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr

	;print area sexta tentativa
	loadn r0, #218
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra verde
	loadn r0, #400
	loadn r1, #Msn3
	loadn r2, #512
	call ImprimeStr
	
	loadn r0, #440
	loadn r1, #Msn4
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra amarela
	loadn r0, #520
	loadn r1, #Msn5
	loadn r2, #2816
	call ImprimeStr
	
	loadn r0, #560
	loadn r1, #Msn6
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra vermelha
	loadn r0, #640
	loadn r1, #Msn7
	loadn r2, #2304
	call ImprimeStr
	
	loadn r0, #680
	loadn r1, #Msn8
	loadn r2, #0
	call ImprimeStr

	pop r2
	pop r1
	pop r0
	pop fr
	rts

; ---------- APAGA TELA ----------
ApagaTela:
	push fr		; Protege o registrador de flags
	push r0
	push r1
	
	loadn r0, #1200		; apaga as 1200 posicoes da Tela
	loadn r1, #' '		; com "espaco"
	
	   ApagaTela_Loop:
		dec r0
		outchar r1, r0
		jnz ApagaTela_Loop
		
	pop r1
	pop r0
	pop fr
	rts