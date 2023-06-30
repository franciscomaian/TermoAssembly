; Termo em Assembly SSC0221 - Introducao a Sistemas Computacionais
;
; Autores:
;	Francisco Maian   	nUSP: 14570890
;	Julia Pravato	  	nUSP: 14615054
;	Leticia Barbanera 	nUSP: 14588642
;

;---------- PROPOSTA: TERMO ----------------------------------------------------------------------
; Descobrir a palavra a ser adivinhada em 6 tentativas. Em cada tentativa,
; as letras mostram dicas sobre a solução. Verdes: letra correta na posição correta; Amarelas:
; letra faz parte da palavra, mas em outra posição; vermelhas: letra não faz parte do termo.

;---------- FEATURES ------------------------------------------------------------------------------
; Dicas de palavras poderem possuir letras repetidas, como no jogo original, função de backspace
; durante as tentativas e esperar pressionar o enter para confirmar a tentativa. Opção de jogar
; diretamente no fim do jogo. 

jmp main

Palavra: var #6			   	; Palavra a ser adivinhada
PalavraTentativa: var #6   	; Palavra chutada
PalavraVerificacao: var #6 	; Palavra verificada
PalavraVerde: var #5	   	; Locais que foi detectado a letra certa na posicao certa
NumTentativa: var #1	   	; Numero da tentativa atual
Letra: var #1			   	; Letra lida pelo teclado
Ganhou: var #1			   	; Flag: Variavel de vitoria
JogarNovamente: var #1	   	; Flag: Variavel para jogar novamente

; Mensagens que serao impressas na tela
textoInicial: string "Digite uma palavra de 5 letras:"
termo: 		  string "TERMO"
espaco:       string "_____"
verde1:  	  string "Letra verde:"
verde2:  	  string " Letra certa na posicao certa"
amarelo1:     string "Letra amarela:"
amarelo2:     string " Letra certa na posicao errada"
vermelho1:    string "Letra vermelha:"
vermelho2:    string " Letra errada"
apagarTexto:  string "Para apagar a letra digite -"
vitoria:      string "Voce Venceu! :)"
derrota:      string "Voce Perdeu! :/"
textoPalavra: string "Resposta: "
jogardenovo:  string "Quer jogar novamente? <s/n>"
linhabranca:  string "                                        "

;---------- PROGRAMA PRINCIPAL -----------------------------------------------------------------------------
main:
	
	; Inicializando e zerando as variaveis globais:
	loadn r0, #0				; define 0 para zerar variáveis globais
	store NumTentativa, r0		; Contador de Tentativas
	store Ganhou, r0			; flag de Ganhou em 0
	store JogarNovamente, r0	; flag de JogarNovamente em 0
	load r1, NumTentativa		; carrega r1 em 0 (contador principal de tentativas) 
	loadn r2, #6				; carrega r2 em 6, número máximo de tentativas
	loadn r3, #1				; carrega r3 em 1, para a verificação de flags binárias

	call inputPalavra 	; ler a palavra a ser adivinhada

	call chamaJogo		; configura toda a tela de jogo
	
	loopjogo:
		call checarPalavra			; ler a palavra de tentativa 
		inc r1						; incrementa o numero de tentativas
		store NumTentativa, r1		; marca na variável o número atual de tentativas
		call TestaVitoria			; verifica se houve vitória durante a tentativa
		load r4, Ganhou				; carrega em r4 a flag de Ganhou naquela tentativa
		cmp r4, r3					; se sim, declara as configurações de fim de jogo
		jeq fimJogo					
		cmp r1, r2					; se não, confere se não estourou o número de tentativas
		jne loopjogo				; não estourando, próxima tentativa
		
		fimJogo:
		call jogarDenovo			; ganhando ou perdendo, opção de jogar novamente
		call ApagaTela				; apaga toda tela ao fim do jogo
		load r4, JogarNovamente		; carrega em r4 a flag de JogarNovamente
		cmp r4, r3					; se sim, retoma a main 
		jeq main

	halt ; finalização do termo

; Métodos:
;---------- LER PALAVRA A SER ADIVINHADA -------------------------------------------------------------------
inputPalavra:	; lê palavra a ser adivinhada

	push fr ; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0 ; recebe a letra digitada 
	push r1 ; contador de quantidade de letras (index) - palavra de 5 letras
	push r2 ; ponteiro para palavra (endereço na memória)
	push r3 ; ponteiro para a palavra a ser adivinhada + index de qual letra na string
	push r4 ; comparador para o tamanho da palavra

	loadn r1, #0			; contador de quantidade de letras em 0 (index)
	loadn r2, #Palavra		; ponteiro para palavra (endereço na memória)
	loadn r4, #5			; comparador para o tamanho da palavra

	call printTextoInicial	; printa os textos iniciais na tela 

   inputPalavra_Loop:		; leitura de letras para preencher a palavra a ser adivinhada 
		call digLetra		; espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra		; Letra --> r0

		add r3, r2, r1		; ponteiro para a palavra a ser adivinhada + index de qual letra na string -> r3
		storei r3, r0		; palavra[r3] = nova letra

		inc r1						; incrementa index da string
		cmp r1, r4					; verifica se o tamanho da palavra já preencheu 5
		jne inputPalavra_Loop		; se sim, vai para o jogo, se não retorna para pegar mais uma letra
				
	; coloca \0 no final da palavra
	loadn r0, #0			; letra "digitada" recebe \0
	add r3, r2, r1			; ponteiro para a palavra a ser adivinhada + index de última letra na string
	storei r3, r0			; palavra[5] = \0

	pop r4	; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0	
	pop fr
	rts		; retorno de subrotina
	
;---------- SETA CONFIGURACOES PARA IMPRIMIR TEXTO INICIAL -------------------------------------------------
printTextoInicial: 	; seta configurações para tela inicial: "digite o termo:"

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0		
	push r1			
	push r2
	
	loadn r0, #0				; posicao na tela onde a mensagem sera escrita
	loadn r1, #textoInicial		; carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0				; define a cor da Mensagem (Branco)
	call ImprimeStr				; função: imprimir string
	
	pop r2			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r1
	pop r0	
	pop fr		
	rts             ; retorno de subrotina
	
;---------- IMPRIME STRING ---------------------------------------------------------------------------------
ImprimeStr:	;  Rotina de Impresao de Mensagens: Obs: a mensagem será impressa até encontrar "/0"

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0			; posicao da tela que o primeiro caractere da mensagem será impresso
	push r1			; endereço onde a mensagem inicia (ponteiro para uma string de final "/0")
	push r2			; cor da mensagem
	push r3			; protege o r3 na pilha para ser usado na subrotina
	push r4			; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1			; carrega r4 com o conteúdo de r1 (ponteiro da string)
		cmp r4, r3				; compara com caractere "/0" 
		jeq ImprimeStr_Sai		; se sim, final da subrotina
		add r4, r2, r4			; define a mensagem colorida
		outchar r4, r0			; mostra na posicao da tela o caractere
		inc r0					; próxima posição na tela
		inc r1					; próximo caractere da string a ser impresso
		jmp ImprimeStr_Loop		; imprime mais um caracter no loop
	
   ImprimeStr_Sai:	
	pop r4			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina
	
;---------- LER LETRA --------------------------------------------------------------------------------------
digLetra:	; espera que uma tecla seja digitada e salva na variavel global "Letra"

	push fr 	; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0
	push r1		
	push r2
	
	loadn r1, #255		; enquanto na espera de digitar algo, retorna 255
	loadn r2, #0		; logo que programa a FPGA o inchar vem 0

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

; ---------- DESENHA O JOGO --------------------------------------------------------------------------------
chamaJogo: 	; configura toda a tela de jogo (regras, espaços de tentativas e comando backspace como '-')
	
	push fr 		; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0
	push r1
	push r2

	call ApagaTela	; apaga as 1200 posicoes da Tela, tela inteira preta
	
	;print titulo termo
	loadn r0, #58		; posicão na tela para imprimir o primeiro caractere da string
	loadn r1, #termo	; ponteiro apontando o primeiro caractere da string 
	loadn r2, #0		; cor da mensagem
	call ImprimeStr		; função: impressão da mensagem
	
	;print area primeira tentativa
	loadn r0, #178
	loadn r1, #espaco
	loadn r2, #0
	call ImprimeStr
	
	;print area segunda tentativa
	loadn r0, #218
	call ImprimeStr
	
	;print area terceira tentativa
	loadn r0, #258
	call ImprimeStr

	;print area quarta tentativa
	loadn r0, #298
	call ImprimeStr

	;print area quinta tentativa
	loadn r0, #338
	call ImprimeStr

	;print area sexta tentativa
	loadn r0, #378
	call ImprimeStr
	
	;print texto letra verde
	loadn r0, #480
	loadn r1, #verde1
	loadn r2, #512
	call ImprimeStr
	
	loadn r0, #520
	loadn r1, #verde2
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra amarela
	loadn r0, #600
	loadn r1, #amarelo1
	loadn r2, #2816
	call ImprimeStr
	
	loadn r0, #640
	loadn r1, #amarelo2
	loadn r2, #0
	call ImprimeStr
	
	;print texto letra vermelha
	loadn r0, #720
	loadn r1, #vermelho1
	loadn r2, #2304
	call ImprimeStr
	
	loadn r0, #760
	loadn r1, #vermelho2
	loadn r2, #0
	call ImprimeStr
	
	loadn r0, #840
	loadn r1, #apagarTexto
	loadn r2, #0
	call ImprimeStr

	pop r2		; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r1
	pop r0
	pop fr
	rts 		; retorno de subrotina

; ---------- APAGA TELA ------------------------------------------------------------------------------------
ApagaTela: 	; apaga as 1200 posições da Tela, tela em preto
	
	push fr		; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0
	push r1
	
	loadn r0, #1200		; carrega r0 com 1200, equivalente a todas as posições na tela
	loadn r1, #' '		; carrega r1 com "espaço" em branco
	
	ApagaTela_Loop:
		dec r0					; começa do 1199 e decrementa até a posição 0
		outchar r1, r0			; mostra um " " na posição
		jnz ApagaTela_Loop		; termina o loop até apagar a tela por completo
		
	pop r1		; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r0
	pop fr
	rts 		; retorno de subrotina

; ---------- INPUT PALAVRA ---------------------------------------------------------------------------------
checarPalavra:	; recebe uma palavra de tentativa e retorna na tela o resultado das suas letras nas cores
	
	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0			; contador para as letras [index]
	push r1			;
	push r2			; comparador para o tamanho 5
	push r3			; ponteiro para a string de cópia da palavra a ser adivinhada
	push r4			; ponteiro para a string de palavra tentativa atual
	push r5			; ponteiro + index nas strings
	push r6			; auxiliar para comaparação entre string tentativa e string de verificação
	push r7			; auxiliar para comaparação entre string tentativa e string de verificação
	
	loadn r0, #0 						; contador para as letras palavra testada
	loadn r2, #5						; comparador para o tamanho 5
	
	call resetaPalavras					; define, copia e seta as strings para verificações (cópia, sobreposição verdes)
	loadn r3, #PalavraVerificacao		; r3 carregado com o ponteiro para a string de cópia da palavra a ser adivinhada
	
	call inputPalavraTentativa			; ler palavra de tentativa, features de backspace, e espera confirmação
	loadn r4, #PalavraTentativa			; r4 carregado com o ponteiro para a string de palavra tentativa atual
	
	ComparaLetrasVerdes:		; garante a impressão, sem sobreposição das letras certas nas posições certas
		cmp r0, r2 				; verifica se o tamanho da palavra já chegou em 5
		jeq InicioComparaTentativa		; se sim, vai para a função de avaliar a tentativa
		
		; checa se a letra certa esta na posicao certa - Verde
		add r5, r4, r0		; ponteiro da string de palavra de tentativa + index na string -> r5
		loadi r6, r5 		; r6 esta com a letra testada na tentativa
		add r5, r3, r0		; ponteiro da string de cópia da palavra a ser adivinhada + index na string -> r5
		loadi r7, r5 		; r7 esta com a letra da palavra certa na mesma posicao da letra testada na tentativa
		cmp r6, r7 			; se as duas letras forem iguais, printa letra em verde
		jeq PrintarVerde	; mostra na tela a letra certa na posição certa
		inc r0				; avança para o próximo caractere na string, incremento no index
		jmp ComparaLetrasVerdes		
	
	PrintarVerde:			; após verificação, printa letra verde na tela
		call letraVerde		; escreve a letra verde: letra certa na posição certa + marca o vetor booleano de verificação de verdes
		inc r0				; avança para o próximo caractere na string, incremento no index
		jmp ComparaLetrasVerdes	
		
	InicioComparaTentativa:
	loadn r0, #0 				; contador para as letras palavra a ser adivinhada[index]
	
	ComparaTentativa:
		loadn r1, #0 			; contador para as letras palavra a ser adivinhada[index]
		cmp r0, r2 				; verifica se o tamanho da palavra já preencheu 5
		jeq fimChecar			; se não, verifica a possibilidade dessa letra estar amarela ou vermelha
		
		;checa se a letra é certa mas esta na posicao errada
		ComparaAmarelo:
			add r5, r4, r0		; atualiza ponteiro + index para as strings
			loadi r6, r5 		; r6 esta com a letra da tentativa na posição index
			add r5, r3, r1		; atualiza ponteiro + index para a string de cópia da palavra a ser adivinhada
			loadi r7, r5 		; r7 esta com a letra da palavra a ser adivinhada na posiçao do index
			cmp r6, r7			; compara para ver se a letra está na palavra
			jeq PrintarAmarelo	; se sim, printa ela como amarela
			inc r1				; se não, incrementa o index 
			cmp r1, r2			; se ainda não atingir o tamanho de 5, compara com as próximas letras na string certa
			jne ComparaAmarelo
	
	
		call letraVermelha		; passando pelos casos de verde e amarelo, a única possibilidade é uma letra vermelha
		inc r0					; incrementa o index das strings
		jmp ComparaTentativa
		
		PrintarAmarelo:
			call letraAmarela	; escreve a letra amarela: letra certa mas na posição errada
			inc r0				; incrementa o index das strings
			jmp ComparaTentativa
	
	fimChecar:
	
	pop r7			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina
	
;---------- RESETA PALAVRAS --------------------------------------------------------------------------------
resetaPalavras:		; define, copia e seta as strings para verificações

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0			; ponteiro da string a ser adivinhada 
	push r1			; ponteiro para a verificação: cópia da string a ser adivinhada
	push r2			; contador de letras
	push r3			; registrador auxiliar para essa função
	push r4			; index durante as strings
	push r5			; ponteiro para a string de 0s e 1s para a verificacao de letras verdes (sem casos de sobreposição)
	
	loadn r0, #Palavra					; r0 recebe o ponteiro da string a ser adivinhada 
	loadn r1, #PalavraVerificacao		; r1 recebe uma cópia da string a ser adivinhada
	loadn r2, #5						; contador de letras (vai ate 5)
	loadn r4, #0						; index durante as strings
	loadn r5, #PalavraVerde				; vetor de 0s e 1s para a verificacao de letra certa na posição certa (sem casos de sobreposição)
	
	ComparaPalavraVerificacao:
		loadi r3, r0				; carrega r3 com o conteúdo de r0 (ponteiro da string a ser adivinhada)
		storei r1, r3				; carrega a letra na cópia de string a ser adivinhada
		storei r5, r2				; por questão de economia de registradores, 5 = 0 = boolFalse, no vetor de verdes
		inc r4						; próximo index durante a string
		inc r0						; leitura da próxima letra da string a ser adivinhada original
		inc r1						; próximo caractere a ser lido e copiado na string de verificação
		inc r5						; próximo valor booleano a ser captado no vetor de verificação de verdes
		cmp r2, r4					; se todos os index da palavra de 5 letras foram copiados
		jne ComparaPalavraVerificacao	; não: avança para o próximo caractere
	
	pop r5		; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 		; retorno de subrotina

;---------- LER PALAVRA TENTATIVA --------------------------------------------------------------------------
inputPalavraTentativa:	; le a palavra a ser adivinhada

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0 		; recebe a letra digitada
	push r1 		; contador de quantidade de letras (index) - palavra de 5 letras
	push r2 		; ponteiro para palavra de tentativa (endereço na memória)
	push r3 		; ponteiro para a palavra a ser adivinhada + index de qual letra na string [r1+r2] & comparador auxiliar
	push r4 		; comparador para o tamanho da palavra
	push r5 		; NumTentativa
	push r6 		; posicao da letra na tela
	push r7			; troca de linha na tela

	loadn r1, #0					; contador de quantidade de letras na palavra de tentativa
	loadn r2, #PalavraTentativa		; ponteiro para palavra de tentativa
	loadn r4, #5					; comparador para o tamanho da palavra
	load r5, NumTentativa			; NumTentativa
	loadn r6, #138					; posição da letra na tela
	loadn r7, #40					; troca de linha na tela
	
	linhaPalavraTentativa:		;achar linha da palavra
		add r6, r6, r7			; define inicio de print da primeira letra da string na próxima linha
		cmp r5, r1				;
		inc r1					; 
		jne linhaPalavraTentativa
	
	loadn r1, #0
   	inputPalavraTentativa_Loop:		; leitura de letras para preencher a palavra a ser adivinhada 
		call digLetra				; espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra				; letra --> r0
	   	
	   	loadn r3, #'-'		; comparador auxiliar
	   	cmp r0, r3			; se letra for equivalente ao nosso backspace
	   	jeq backspace		; função backspace

		add r3, r2, r1		; palavra a ser adivinhada[index atual]
		storei r3, r0		; palavra a ser adivinhada[index atual] = Letra
		
		;printar a letra em branco - escrita esperando confirmação e possibilidade de backspace
		outchar r0, r6		; mostra letra digitada na sua posição da tela
		inc r6				; próxima posição na tela
		
		inc r1								; próximo index na string de palavra tentativa
		cmp r1, r4							; verifica se o tamanho da palavra já preencheu 5
		jne inputPalavraTentativa_Loop		; se não, preenche a string de palavra tentativa
		jmp fim_backspace					; se sim, vai para o fim da função com a string de palavra tentativa definida
		
		backspace:		; função backspace pela tecla "-"
		loadn r3, #0		; garante que não estamos com 0 caracteres na string
		cmp r1, r3			; se sim, nada deve ocorrer
		jeq inputPalavraTentativa_Loop		; voltamos ao loop para pegar uma letra
		loadn r3, #'_'		; se não, queremos de fato dar o backspace
		dec r1				; voltamos um index da string de palavra tentativa
		dec r6				; voltamos uma posição na exposição da tela
		outchar r3, r6		; retornamos o caractere como "_" espaço para colocar a nova letra
		jmp inputPalavraTentativa_Loop		; volta para o loop principal e conseguir outras letras
		
		fim_backspace:		; fim geral para essa subrotina, no final da string esperando confirmação
		
		call digLetra		; espera que uma tecla seja digitada e salva na variavel global "Letra"
	   	load r0, Letra		; Letra --> r0
	   	
	   	loadn r3, #'-'		; comparador auxiliar
	   	cmp r0, r3			; se letra for equivalente ao nosso backspace
	   	jeq backspace		; função backspace
	   	
	   	loadn r3, #13		; comparador auxiliar
	   	cmp r3, r0			; se letra for equivalente for a confirmação "enter"
	   	jne fim_backspace	; se não, retoma para pegar outra letra
				
	; coloca \0 no final da palavra
	loadn r0, #0			; letra "digitada" recebe \0
	add r3, r2, r1			; ponteiro para a palavra a ser adivinhada + index de última letra na string
	storei r3, r0			; palavra[5] = \0

	pop r7		; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0	
	pop fr
	rts  		; retorno de subrotina

;---------- ESCREVER LETRA VERDE ---------------------------------------------------------------------------
letraVerde:		; escreve a letra verde: letra certa na posição certa + marca o vetor booleano de verificação de verdes

	push fr		; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0		; r0 = posicao da letra
	push r1 	; NumTentativa
	push r2 	; posicao da letra (inicialmente 178, primeira letra da primeira tentativa)
	push r3 	; constante para a próxima linha + 40
	push r4 	; contador para as letras [index]
	push r5		; r5 = ponteiro para a string de cópia da palavra a ser adivinhada
	push r6		; r6 = letra a ser printada
	push r7 	; cor verde
	
	load r1, NumTentativa
	loadn r2, #178
	loadn r3, #40
	loadn r4, #0
	storei r5, r4			
	
	LinhaVerde:
		cmp r1, r4				; se estiver na primeira tentativa(0) não faz o processo de incremento de linha
		jeq fim_LinhaVerde		; se sim, diretamente pra a impressão de letra verde
		add r2, r2, r3			; se não, incremento na linha, próxima linha em index 0
		inc r4					; próximo index na string
		jmp LinhaVerde			; determina a linha em que está
	
	fim_LinhaVerde:
	
	loadn r4, #0				; reinicia o index da string
	ColunaVerde:
		cmp r4, r0				; se a posição da letra for igual ao index atual na string
		jeq fim_ColunaVerde		; define a string verde de verificação
		inc r2					; próxima posição na tela
		inc r4					; próxima posição da string
		jmp ColunaVerde
	
	fim_ColunaVerde:
	
	loadn r7, #PalavraVerde		; ponteiro da string de verificação booleana de letras verdes
	add r7, r7, r4				; index para movimentação na string
	storei r7, r3				; valor de 40 como True = 1, ou seja, letra é verde e não será mais avaliada
	
	; mostra na posição, a letra verde na tela
	loadn r7, #512 				; cor verde
	add r6, r7, r6				; letra verde para print na posição 
	outchar r6, r2				; mostra a letra verde na tela
	
	pop r7			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina

;---------- ESCREVER LETRA AMARELA -------------------------------------------------------------------------
letraAmarela:	; escreve a letra amarela: letra certa mas na posição errada 

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0			; r0 = posicao da letra
	push r1 		; NumTentativa
	push r2 		; posicao da letra (inicialmente 178, primeira letra da primeira tentativa)
	push r3 		; constante para a próxima linha + 40
	push r4 		; contador para as letras [index]
	push r5			; r5 = ponteiro para a string de cópia da palavra a ser adivinhada
	push r6			; r6 = letra a ser printada
	push r7 		; cor amarela
	
	load r1, NumTentativa
	loadn r2, #178
	loadn r3, #40
	loadn r4, #0
	
	LinhaAmarela:
		cmp r1, r4					; se estiver na primeira tentativa(0) não faz o processo de incremento de linha
		jeq fim_LinhaAmarela		; se sim, diretamente pra a impressão de letra amarela
		add r2, r2, r3				; se não, incremento na linha, próxima linha em index 0
		inc r4						; próximo index na string
		jmp LinhaAmarela			; determina a linha em que está
		
	fim_LinhaAmarela:
	
	loadn r4, #0				; reinicia o index da string
	ColunaAmarela:
		cmp r4, r0				; se a posição da letra for igual ao index atual na string
		jeq fim_ColunaAmarela	; define a string verde de verificação
		inc r2					; próxima posição na tela
		inc r4					; próxima posição da string
		jmp ColunaAmarela
	
	fim_ColunaAmarela:
	
	loadn r7, #PalavraVerde		; ponteiro da string de verificação booleana de letras verdes
	add r7, r7, r4				; index para movimentação na string
	loadi r4, r7				; verifica se a letra ainda pode ser avaliada dado o vetor de booleano para avaliação de verdes
	cmp r4, r3					; garante a não sobreposição de uma letra que já estava certa, na posição certa
	jeq fimAmarelo
	
	loadn r4, #0		; reinicia o index da string
	storei r5, r4		; reinicia o ponteiro para a cópia de palavra certa
	
	loadn r7, #2816 	; cor amarela
	add r6, r7, r6		; letra amarela para print na posição 
	outchar r6, r2		; mostra letra amarela na tela
	
	fimAmarelo:
	
	pop r7			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina

;---------- ESCREVER LETRA VERMELHA ------------------------------------------------------------------------
letraVermelha:	; escreve a letra vermelha: letra errada, não está na palavra de nenhuma forma

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0			; r0 = posicao da letra
	push r1 		; NumTentativa
	push r2 		; posicao da letra (inicialmente 178, primeira letra da primeira tentativa)
	push r3 		; constante para a próxima linha + 40
	push r4 		; contador para as letras [index]
	push r5			; r5 = ponteiro para a string de cópia da palavra a ser adivinhada
	push r6			; r6 = letra a ser printada
	push r7 		; cor vermelha
	
	load r1, NumTentativa
	loadn r2, #178
	loadn r3, #40
	loadn r4, #0
	
	LinhaVermelha:
		cmp r1, r4					; se estiver na primeira tentativa(0) não faz o processo de incremento de linha
		jeq fim_LinhaVermelha		; se sim, diretamente pra a impressão de letra vermelha
		add r2, r2, r3				; se não, incremento na linha, próxima linha em index 0
		inc r4						; próximo index na string
		jmp LinhaVermelha			; determina a linha em que está
	
	fim_LinhaVermelha:
	
	loadn r4, #0				; reinicia o index da string
	ColunaVermelha:
		cmp r4, r0				; se a posição da letra for igual ao index atual na string
		jeq fim_ColunaVermelha	; define a string verde de verificação
		inc r2					; próxima posição na tela
		inc r4					; próxima posição da string
		jmp ColunaVermelha
	
	fim_ColunaVermelha:
	
	loadn r7, #PalavraVerde		; ponteiro da string de verificação booleana de letras verdes
	add r7, r7, r4				; index para movimentação na string
	loadi r4, r7				; verifica se a letra ainda pode ser avaliada dado o vetor de booleano para avaliação de verdes
	cmp r4, r3					; garante a não sobreposição de uma letra que já estava certa, na posição certa
	jeq fimVermelho
	
	loadn r7, #2304 	; cor vermelha
	add r6, r7, r6		; letra vermelha para print na posição 
	outchar r6, r2		; mostra letra vermelha na tela
	
	fimVermelho:
	
	pop r7			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina

;---------- TESTA VITORIA ----------------------------------------------------------------------------------
TestaVitoria:	; verifica se o jogador venceu o jogo durante a tentativa

	push fr			; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0 		; ponteiro a palavra a ser adivinhada
	push r1 		; ponteiro palavra de tentativa
	push r2			; letra da palavra a ser adivinhada, ponteiro[index]
	push r3 		; letra da palavra de tentativa, ponteiro[index]
	push r4 		; contador para as letras [index]
	push r5 		; comparador para o tamanho da palavra
	push r6 		; se ganhou a flag Ganhou aciona em 1
	
	loadn r0, #Palavra
	loadn r1, #PalavraTentativa
	loadn r4, #0
	loadn r5, #5
	loadn r6, #1
	
	loop_Vitoria:
		loadi r2, r0		; ponteiro a palavra a ser adivinhada[0]
		loadi r3, r1		; ponteiro palavra de tentativa[0]
		cmp r2, r3			; se não forem iguais, não ganhou nesta tentativa
		jne fim_Vitoria
		inc r0				; próximo index da string de palavra a ser adivinhada
		inc r1				; próximo index da string de palavra de tentativa
		inc r4				; próximo na contagem de letras na palavra
		cmp r4, r5			; se não chegou em 5 ainda, continua a verificação
		jne loop_Vitoria
	
	store Ganhou, r6		; confirma a flag de Ganhou
	
	fim_Vitoria:
	
	pop r6			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina

;---------- JOGAR DENOVO -----------------------------------------------------------------------------------
jogarDenovo: 	; mostra a resposta do termo, se o jogador venceu ou perdeu e pergunta se quer recomecar o jogo

	push fr		; protege os registradores de flags e outros na pilha para preservar seus valores durante a subrotina
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	;limpar as regras da tela
	loadn r0, #480			; posição da linha na tela
	loadn r1, #linhabranca	; escrito de linha em branco "    "	
	loadn r2, #0			; cor branca
	call ImprimeStr		
	loadn r0, #520
	call ImprimeStr
	
	loadn r0, #600
	call ImprimeStr
	loadn r0, #640
	call ImprimeStr
	
	loadn r0, #720
	call ImprimeStr
	loadn r0, #760
	call ImprimeStr
	
	loadn r0, #840
	call ImprimeStr
	
	; verificação se ganhou
	load r3, Ganhou		; carrega em r3 a flag Ganhou
	loadn r4, #1		; comparador de flag em nível lógico alto
	cmp r3, r4			; se a flag estiver alta, ganhou
	jne perdeuJogo		; se não, perdeu
	
	; printa frase ganhou jogo
	loadn r0, #493		
	loadn r1, #vitoria
	loadn r2, #0
	call ImprimeStr
	
	jmp printarPalavraCerta
	
	perdeuJogo: 	; printa frase perdeu jogo
	loadn r0, #493
	loadn r1, #derrota
	loadn r2, #0
	call ImprimeStr
	
	printarPalavraCerta:	; independente do resultado, apresenta em verde o termo a ser adivinhado
	loadn r0, #573
	loadn r1, #textoPalavra
	loadn r2, #0
	call ImprimeStr
	
	loadn r0, #583
	loadn r1, #Palavra
	loadn r2, #512
	call ImprimeStr
	
	; printa frase se quer jogar novamente o jogo
	loadn r0, #687
	loadn r1, #jogardenovo
	loadn r2, #0
	call ImprimeStr
	
	call digLetra		; espera que uma tecla seja digitada e salva na variavel global "Letra"
	load r5, Letra		; Letra -> r5
	loadn r6, #'s'		; comparador para letra "s" de sim, quero jogar novamente
	
	cmp r5, r6			; se não clicar em "s", jogo termina.
	jne fimfim
	
	store JogarNovamente, r4 	; flag de JogarNovamente em nível lógico alto
	
	fimfim:
	
	pop r6			; resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop fr
	rts 			; retorno de subrotina

; 454