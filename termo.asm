;Termo em Assembly feito para materia SSC0221 - Introducao a Sistemas Computacionais
;
;Autores:
;	Francisco Maian   nUSP: 14570890
;	Julia Pravato	  nUSP: 14615054
;	Leticia Barbanera nUSP: 
;

jmp main

Palavra: var #6			 ; Palavra a ser adivinhada
PalavraTentativa: var #6 ; Palavra chutada
NumTentativa: var #1	 ; Tentativa atual
Letra: var #1			 ; letra lida pelo teclado

; Mensagens que serao impressas na tela
textoInicial: string "Digite uma palavra de 5 letras:"
espaco:       string "_____"
verde1:  	  string "Letra verde:"
verde2:  	  string " Letra certa na posicao certa"
amarelo1:     string "Letra amarela:"
amarelo2:     string " Letra certa na posicao errada"
vermelho1:    string "Letra vermelha:"
vermelho2:    string " Letra errada"
vitoria:      string "Voce Venceu! :)"
derrota:      string "Voce Perdeu! :/"
jogardenovo:  string "Quer jogar novamente? <s/n>"

;---------- PROGRAMA PRINCIPAL ----------
main:
	; Inicializando e zerando as variaveis globais:
	loadn r0, #0
	store NumTentativa, r0	; Contador de Tentativas
	load r1, NumTentativa
	loadn r2, #6

	call inputPalavra ; Ler a palavra a ser adivinhada

	call chamaJogo
	
	loopjogo:
		call checarPalavra
		inc r1
		store NumTentativa, r1
	;	call TestaFim
		cmp r1, r2
		jne loopjogo
		
		;call jogarDenovo

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

	call printTextoInicial	; Printa a Msn1

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

;---------- SETA CONFIGURACOES PARA IMPRIMIR TEXTO INICIAL ----------
printTextoInicial:
	push fr
	push r0
	push r1
	push r2
	
	loadn r0, #0		; Posicao na tela onde a mensagem sera escrita
	loadn r1, #textoInicial		; Carrega r1 com o endereco do vetor que contem a mensagem
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
	loadn r1, #espaco
	loadn r2, #0
	call ImprimeStr
	
	;print area segunda tentativa
	loadn r0, #58
	call ImprimeStr
	
	;print area terceira tentativa
	loadn r0, #98
	call ImprimeStr

	;print area quarta tentativa
	loadn r0, #138
	call ImprimeStr

	;print area quinta tentativa
	loadn r0, #178
	call ImprimeStr

	;print area sexta tentativa
	loadn r0, #218
	call ImprimeStr
	
	;print texto letra verde
	loadn r0, #400
	loadn r1, #verde1
	loadn r2, #512
	call ImprimeStr
	
	loadn r0, #440
	loadn r1, #verde2
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra amarela
	loadn r0, #520
	loadn r1, #amarelo1
	loadn r2, #2816
	call ImprimeStr
	
	loadn r0, #560
	loadn r1, #amarelo2
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra vermelha
	loadn r0, #640
	loadn r1, #vermelho1
	loadn r2, #2304
	call ImprimeStr
	
	loadn r0, #680
	loadn r1, #vermelho2
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

; ---------- INPUT PALAVRA ----------
checarPalavra:
	push fr
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r0, #0 ; contador palavra testada
	loadn r2, #5
	loadn r3, #Palavra
	
	call inputPalavraTentativa
	loadn r4, #PalavraTentativa
	
	ComparaTentativa:
		cmp r0, r2 ; loop ja passou as 5 letras
		jeq fimChecar
		
		;checa se a letra certa esta na posicao certa
		add r5, r4, r0
		loadi r6, r5 ; r6 esta com a letra testada
		add r5, r3, r0
		loadi r7, r5 ; r7 esta com a letra da palavra certa na mesma posicao da letra testada
		cmp r6, r7 ; se as duas letras forem a mesma printa verde
		jeq PrintarVerde
		
		;checa se a letra certa esta na posicao errada
		loadn r1, #0 ; contador palavra certa
		ComparaAmarelo:
			add r5, r3, r1
			loadi r7, r5 ; r7 esta com a letra da palavra certa na posicao r1
			cmp r6, r7
			jeq PrintarAmarelo
			inc r1
			cmp r1, r2
			jne ComparaAmarelo
	
	
		call letraVermelha
		inc r0
		jmp ComparaTentativa
	
		PrintarVerde:
			call letraVerde
			inc r0
			jmp ComparaTentativa
		
		PrintarAmarelo:
			call letraAmarela
			inc r0
			jmp ComparaTentativa
	
	fimChecar:
	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	
	rts

;---------- LER PALAVRA TENTATIVA ----------
inputPalavraTentativa:	; Le a palavra a ser adivinhada

	push fr ; protege o registrador de flags
	push r0 ; recebe a letra digitada
	push r1 ; contador de letras (vai ate 5)
	push r2 ; ponteiro para a palavra
	push r3 ; palavra[r2+r1]
	push r4 ; tamanho da palavra

	loadn r1, #0		; contador de quantidade de letras
	loadn r2, #PalavraTentativa	; ponteiro para palavra
	loadn r4, #5		; Tamanho da palavra

   inputPalavraTentativa_Loop:
		call digLetra	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra	; Letra --> r0

		add r3, r2, r1
		storei r3, r0	; palavra[r2] = Letra

		inc r1
		cmp r1, r4						; verifica se o tamanho da palavra eh 5
		jne inputPalavraTentativa_Loop	; Se for, vai para o jogo
				
	;Coloca \0 no final da palavra
	loadn r0, #0
	add r3, r2, r1
	storei r3, r0	; palavra[r2] = /0

	pop r4
	pop r3
	pop r2
	pop r1
	pop r0	
	pop fr
	rts

;r6 = letra a ser printada
;r0 = posicao da letra
;---------- ESCREVER LETRA VERDE ----------
letraVerde:	; escreve a letra verde
	push fr
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5 ; cor verde
	push r6
	
	load r1, NumTentativa
	loadn r2, #18
	loadn r3, #40
	loadn r4, #0
	
	LinhaVerde:
		cmp r1, r4
		jeq fim_LinhaVerde
		add r2, r2, r3
		inc r4
		jmp LinhaVerde
	
	fim_LinhaVerde:
	
	loadn r4, #0
	ColunaVerde:
		cmp r4, r0
		jeq fim_ColunaVerde
		inc r2
		inc r4
		jmp ColunaVerde
	
	fim_ColunaVerde:
	
	loadn r5, #512 ; cor verde
	add r6, r5, r6
	outchar r6, r2
	
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop fr
	rts

;---------- ESCREVER LETRA AMARELA ----------
letraAmarela:	; escreve a letra amarela
	push fr
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5 ; cor amarela
	push r6
	
	load r1, NumTentativa
	loadn r2, #18
	loadn r3, #40
	loadn r4, #0
	
	LinhaAmarela:
		cmp r1, r4
		jeq fim_LinhaAmarela
		add r2, r2, r3
		inc r4
		jmp LinhaAmarela
	
	fim_LinhaAmarela:
	
	loadn r4, #0
	ColunaAmarela:
		cmp r4, r0
		jeq fim_ColunaAmarela
		inc r2
		inc r4
		jmp ColunaAmarela
	
	fim_ColunaAmarela:
	
	loadn r5, #2816 ; cor amarela
	add r6, r5, r6
	outchar r6, r2
	
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop fr
	rts

;---------- ESCREVER LETRA VERMELHA ----------
letraVermelha:	; escreve a letra vermelha
	push fr
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5 ; cor verde
	push r6
	
	load r1, NumTentativa
	loadn r2, #18
	loadn r3, #40
	loadn r4, #0
	
	LinhaVermelha:
		cmp r1, r4
		jeq fim_LinhaVermelha
		add r2, r2, r3
		inc r4
		jmp LinhaVermelha
	
	fim_LinhaVermelha:
	
	loadn r4, #0
	ColunaVermelha:
		cmp r4, r0
		jeq fim_ColunaVermelha
		inc r2
		inc r4
		jmp ColunaVermelha
	
	fim_ColunaVermelha:
	
	loadn r5, #2304 ; cor vermelha
	add r6, r5, r6
	outchar r6, r2
	
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop fr
	rts