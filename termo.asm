; Termo em Assembly feito para materia SSC0221 - Introducao a Sistemas Computacionais
;
; Autores:
;	Francisco Maian   nUSP: 14570890
;	Julia Pravato	  nUSP: 14615054
;	Leticia Barbanera nUSP: 14588642
;

jmp main

Palavra: var #6			   ; Palavra a ser adivinhada
PalavraTentativa: var #6   ; Palavra chutada
PalavraVerificacao: var #6 ; Palavra verificada
PalavraVerde: var #5	   ; Locais que foi detectado a letra certa na posicao certa
NumTentativa: var #1	   ; Tentativa atual
Letra: var #1			   ; Letra lida pelo teclado
Ganhou: var #1			   ; Variavel de vitoria
JogarNovamente: var #1	   ; Variavel para jogar novamente

; Mensagens que serao impressas na tela
textoInicial: string "Digite uma palavra de 5 letras:"
espaco:       string "_____"
verde1:  	  string "Letra verde:"
verde2:  	  string " Letra certa na posicao certa"
amarelo1:     string "Letra amarela:"
amarelo2:     string " Letra certa na posicao errada"
vermelho1:    string "Letra vermelha:"
vermelho2:    string " Letra errada"
apagarletra:  string "Para apagar a letra digite -"
vitoria:      string "Voce Venceu! :)"
derrota:      string "Voce Perdeu! :/"
textoPalavra: string "Resposta: "
jogardenovo:  string "Quer jogar novamente? <s/n>"
linhabranca:  string "                                        "

;---------- PROGRAMA PRINCIPAL ----------
main:
	; Inicializando e zerando as variaveis globais:
	loadn r0, #0
	store NumTentativa, r0	; Contador de Tentativas
	store Ganhou, r0
	store JogarNovamente, r0
	load r1, NumTentativa
	loadn r2, #6
	loadn r3, #1

	call inputPalavra ; Ler a palavra a ser adivinhada

	call chamaJogo
	
	loopjogo:
		call checarPalavra
		inc r1
		store NumTentativa, r1
		call TestaVitoria
		load r4, Ganhou
		cmp r4, r3
		jeq fimJogo
		cmp r1, r2
		jne loopjogo
		
		fimJogo:
		call jogarDenovo
		call ApagaTela
		load r4, JogarNovamente
		cmp r4, r3
		jeq main
		
		

	halt ; finalizacao do termo

; Metodos:
;---------- LER PALAVRA ----------
inputPalavra:	; leitura da palavra a ser adivinhada

	push fr ; protege o registrador de flags
	push r0 ; recebe a letra digitada
	push r1 ; contador de letras (vai ate 5 letras na palavra a ser adivinhada)
	push r2 ; ponteiro para a palavra
	push r3 ; string palavra [r2+r1]
	push r4 ; tamanho da palavra

	loadn r1, #0			; contador de quantidade de letras em 0
	loadn r2, #Palavra		; ponteiro para palavra
	loadn r4, #5			; tamanho da palavra

	call printTextoInicial	; printa os textos iniciais na tela 

   inputPalavra_Loop:		; leitura de letras para preencher a palavra a ser adivinhada 
		call digLetra		; espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra		; letra --> r0

		add r3, r2, r1		; ponteiro para a palavra a ser adivinhada + index de qual letra na string -> r3
		storei r3, r0		; palavra[r3] = nova letra

		inc r1						; incrementa index da string
		cmp r1, r4					; verifica se o tamanho da palavra já preencheu 5
		jne inputPalavra_Loop		; se sim, vai para o jogo, se não retorna para pegar mais uma letra
				
	; coloca \0 no final da palavra
	loadn r0, #0			; letra digitada recebe \0
	add r3, r2, r1			; ponteiro para a palavra a ser adivinhada + index de última letra na string -> r3
	storei r3, r0			; palavra[r3] = \0

	pop r4	; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0	
	pop fr
	rts		; retorno de subrotina
			
;---------- LER LETRA ----------
digLetra:		; espera que uma tecla seja digitada e salva na variavel global "Letra"
	push fr			; protege o registrador de flags e outros registradores do sistema
	push r0
	push r1
	push r2
	
	loadn r1, #255	; se nao digitar nada vem 255
	loadn r2, #0	; logo que programa a FPGA o inchar vem 0

   digLetra_Loop:
		inchar r0			; le o teclado, se nada for digitado = 255
		cmp r0, r1			; compara r0 com 255
		jeq digLetra_Loop	; fica lendo até que digite uma tecla valida
		cmp r0, r2			; compara r0 com 0
		jeq digLetra_Loop	; le novamente pois Logo que programa a FPGA o inchar vem 0

	store Letra, r0			; salva a tecla na variavel global "Letra"
	
   digLetra_Loop2:	
		inchar r0			; le o teclado, se nada for digitado = 255
		cmp r0, r1			; compara r0 com 255
		jne digLetra_Loop2	; fica lendo até que digite uma tecla valida
	
	pop r2		; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r1
	pop r0		
	pop fr
	rts        ; retorno de subrotina

;---------- SETA CONFIGURACOES PARA IMPRIMIR TEXTO INICIAL ----------
printTextoInicial:
	push fr			; protege o registrador de flags e outros registradores do sistema
	push r0
	push r1
	push r2
	
	loadn r0, #0				; posicao na tela onde a mensagem sera escrita
	loadn r1, #textoInicial		; carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0				; seleciona a COR da Mensagem (Branco)
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
	loadn r0, #58
	loadn r1, #espaco
	loadn r2, #0
	call ImprimeStr
	
	;print area segunda tentativa
	loadn r0, #98
	call ImprimeStr
	
	;print area terceira tentativa
	loadn r0, #138
	call ImprimeStr

	;print area quarta tentativa
	loadn r0, #178
	call ImprimeStr

	;print area quinta tentativa
	loadn r0, #218
	call ImprimeStr

	;print area sexta tentativa
	loadn r0, #258
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
	
	loadn r0, #760
	loadn r1, #apagarletra
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
	
	call resetaPalavras
	loadn r3, #PalavraVerificacao
	
	call inputPalavraTentativa
	loadn r4, #PalavraTentativa
	
	ComparaLetrasVerdes:
		cmp r0, r2 ; loop ja passou as 5 letras
		jeq InicioComparaTentativa
		
		;checa se a letra certa esta na posicao certa
		add r5, r4, r0
		loadi r6, r5 ; r6 esta com a letra testada
		add r5, r3, r0
		loadi r7, r5 ; r7 esta com a letra da palavra certa na mesma posicao da letra testada
		cmp r6, r7 ; se as duas letras forem a mesma printa verde
		jeq PrintarVerde
		inc r0
		jmp ComparaLetrasVerdes
	
	PrintarVerde:
		call letraVerde
		inc r0
		jmp ComparaLetrasVerdes
		
	InicioComparaTentativa:
	loadn r0, #0 ; contador palavra certa
	
	ComparaTentativa:
		loadn r1, #0 ; contador palavra certa
		cmp r0, r2 ; loop ja passou as 5 letras
		jeq fimChecar
		
		;checa se a letra certa esta na posicao errada
		ComparaAmarelo:
			add r5, r4, r0
			loadi r6, r5 ; r6 esta com a letra testada
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
	push r5 ; NumTentativa
	push r6 ; posicao da letra na tela
	push r7

	loadn r1, #0		; contador de quantidade de letras
	loadn r2, #PalavraTentativa	; ponteiro para palavra
	loadn r4, #5		; Tamanho da palavra
	load r5, NumTentativa
	loadn r6, #18
	loadn r7, #40
	
	;achar linha da palavra
	linhaPalavraTentativa:
		add r6, r6, r7
		cmp r1, r5
		inc r1
		jne linhaPalavraTentativa
	
	loadn r1, #0
   	inputPalavraTentativa_Loop:
		call digLetra	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra	; Letra --> r0
	   	
	   	loadn r3, #'-'
	   	cmp r0, r3
	   	jeq backspace

		add r3, r2, r1
		storei r3, r0	; palavra[r2] = Letra
		
		;printar a letra em branco
		outchar r0, r6
		inc r6
		
		inc r1
		cmp r1, r4						; verifica se o tamanho da palavra eh 5
		jne inputPalavraTentativa_Loop	; Se for, vai para o jogo
		jmp fim_backspace
		
		backspace:
		loadn r3, #0
		cmp r1, r3
		jeq inputPalavraTentativa_Loop
		loadn r3, #'_'
		dec r6
		dec r1
		outchar r3, r6
		jmp inputPalavraTentativa_Loop
		
		fim_backspace:
		
		call digLetra	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra	; Letra --> r0
	   	
	   	loadn r3, #'-'
	   	cmp r0, r3
	   	jeq backspace
	   	
	   	loadn r3, #13
	   	cmp r3, r0
	   	jne fim_backspace
				
	;Coloca \0 no final da palavra
	loadn r0, #0
	add r3, r2, r1
	storei r3, r0	; palavra[r2] = /0

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

;r0 = posicao da letra
;r6 = letra a ser printada
;r5 = ponteiro pra PalavraVerificacao
;---------- ESCREVER LETRA VERDE ----------
letraVerde:	; escreve a letra verde
	push fr
	push r0
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5
	push r6
	push r7 ; cor verde
	
	load r1, NumTentativa
	loadn r2, #58
	loadn r3, #40
	loadn r4, #0
	storei r5, r4
	
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
	
	loadn r7, #PalavraVerde
	add r7, r7, r4
	storei r7, r3
	
	loadn r7, #512 ; cor verde
	add r6, r7, r6
	outchar r6, r2
	
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

;---------- ESCREVER LETRA AMARELA ----------
letraAmarela:	; escreve a letra amarela
	push fr
	push r0
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5
	push r6
	push r7 ; cor amarela
	
	load r1, NumTentativa
	loadn r2, #58
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
	
	loadn r7, #PalavraVerde
	add r7, r7, r4
	loadi r4, r7
	cmp r4, r3
	jeq fimAmarelo
	
	loadn r4, #0
	storei r5, r4
	loadn r7, #2816 ; cor amarela
	add r6, r7, r6
	outchar r6, r2
	
	fimAmarelo:
	
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

;---------- ESCREVER LETRA VERMELHA ----------
letraVermelha:	; escreve a letra vermelha
	push fr
	push r0
	push r1 ; NumTentativa
	push r2 ; posicao da letra (inicialmente 18)
	push r3 ; linha = 40
	push r4 ; i
	push r5
	push r6
	push r7 ; cor vermelha
	
	load r1, NumTentativa
	loadn r2, #58
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
	
	loadn r7, #PalavraVerde
	add r7, r7, r4
	loadi r4, r7
	cmp r4, r3
	jeq fimVermelho
	
	loadn r7, #2304
	add r6, r7, r6
	outchar r6, r2
	
	fimVermelho:
	
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

;---------- TESTA VITORIA ----------
TestaVitoria: ; verifica se o jogador venceu o jogo
	push fr
	push r0 ; ponteiro palavra certa
	push r1 ; ponteiro palavra tentada
	push r2 ; letra palavra certa
	push r3 ; letra palavra tentada
	push r4 ; contador
	push r5 ; tamanho da palavra
	push r6 ; se ganhou a variavel vai para 1
	
	loadn r0, #Palavra
	loadn r1, #PalavraTentativa
	loadn r4, #0
	loadn r5, #5
	loadn r6, #1
	
	loop_Vitoria:
		loadi r2, r0
		loadi r3, r1
		cmp r2, r3
		jne fim_Vitoria
		inc r0
		inc r1
		inc r4
		cmp r4, r5
		jne loop_Vitoria
	
	store Ganhou, r6
	
	fim_Vitoria:
	
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts

;---------- JOGAR DENOVO ----------
jogarDenovo: ; printa se o jogador venceu ou perdeu e pergunta se quer recomecar o jogo
	push fr
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	;limpar as regras da tela
	loadn r0, #400
	loadn r1, #linhabranca
	loadn r2, #0
	call ImprimeStr
	loadn r0, #440
	call ImprimeStr
	
	loadn r0, #520
	call ImprimeStr
	loadn r0, #560
	call ImprimeStr
	
	loadn r0, #640
	call ImprimeStr
	loadn r0, #680
	call ImprimeStr
	
	loadn r0, #760
	call ImprimeStr
	
	; verifica se ganhou
	load r3, Ganhou
	loadn r4, #1
	
	cmp r3, r4
	jne perdeuJogo
	
	;printa frase ganhou jogo
	loadn r0, #413
	loadn r1, #vitoria
	loadn r2, #0
	call ImprimeStr
	
	jmp printarPalavraCerta
	
	perdeuJogo:
	;printa frase perdeu jogo
	loadn r0, #413
	loadn r1, #derrota
	loadn r2, #0
	call ImprimeStr
	
	printarPalavraCerta:
	loadn r0, #493
	loadn r1, #textoPalavra
	loadn r2, #0
	call ImprimeStr
	
	loadn r0, #503
	loadn r1, #Palavra
	loadn r2, #512
	call ImprimeStr
	
	loadn r0, #567
	loadn r1, #jogardenovo
	loadn r2, #0
	call ImprimeStr
	
	call digLetra
	load r5, Letra
	loadn r6, #'s'
	
	cmp r5, r6
	jne fimfim
	
	store JogarNovamente, r4 ; JogarNovamente = 1
	
	fimfim:
	
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts

;---------- RESETA PALAVRAS ----------
resetaPalavras:
	push fr
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	
	loadn r0, #Palavra
	loadn r1, #PalavraVerificacao
	loadn r2, #5
	loadn r4, #0
	loadn r5, #PalavraVerde
	
	ComparaPalavraVerificacao:
		loadi r3, r0
		storei r1, r3
		storei r5, r2
		inc r0
		inc r1
		inc r4
		inc r5
		cmp r2, r4
		jne ComparaPalavraVerificacao
	
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts