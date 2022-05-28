; Samantha Dantas Medeiros (GitHub: @sammid37)
; 27/05/2022
.686
.model flat, stdcall
    option casemap: none
    .xmm

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc
    include \masm32\include\msvcrt.inc
    include \masm32\macros\macros.asm
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\msvcrt.lib
.data
    ;------Variáveis referentes ao menu de opcaoes
    msg_sistema db "BEM-VINDO AO SISTEMA DE NOTAS", 0AH, 0
    msg_menu_1 db "1-Incluir notas de alunos", 0AH, 0
    msg_menu_2 db "2-Exibir medias de alunos", 0AH, 0
    msg_menu_3 db "3-Sair", 13,10, 0AH, 0

    op_1_msg db "Vamos adicionar os alunos e as notas", 0AH, 0
    op_2_msg db "Vamos exibir as medias", 0AH, 0
    op_3_msg db "Obrigado por usar o sistema", 0AH, 0
    
    msg_opcao db "Digite a opcao desejada: ", 0H ; unsigned char, pergunta
    ;msg_op_select db "A opcao escolhida foi %d", 0AH, 0
    opcao db 5 dup(0) ; usigned char, armazena a opcao do usuario (resposta para msg_opcao)

    aux_handle dd 0 ; auxiliar de opcao
    input_handle dd 0
    output_handle dd 0
    tamanho_string dd 0
    count dd 0
    
    ;------Variaveis referentes a opcao 1 
    msg_nome db "Insira o nome do aluno: ", 0H, 0
    msg_nota_1 db "Nota 1: ", 0H, 0
    msg_nota_2 db "Nota 2: ", 0H, 0
    msg_nota_3 db "Nota 3: ", 0H, 0

    nome_aluno db 15 dup(0) ; Armazena o nome do aluno
    n1 REAL4 0.0 ; Armazena a nota 1
    n2 REAL4 0.0 ; Armazena a nota 2
    n3 REAL4 0.0 ; Armazena a nota 3


    soma_notas REAL4 0.0 ;soma as notas do aluno
    media_aluno REAL4 0.0 ;calcula a media do aluno
    qtd_alunos dd 0 , 0;contador, armazena a qtd de alunos

    ;------Variaveis referentes a opcao 2
    msg_qtd_alunos db "Foram registrados %d alunos.", 0AH, 0
    msg_limite db "Limite de alunos atingido.", 0AH, 0

.code
; pilha de execução, inserir notas

; pilha de execução, somar notas

; pilha de execução, calcular media


start:
    ;------------Mensagem de Bem-vindo e opcoes
    menu:
        invoke GetStdHandle, STD_OUTPUT_HANDLE 
        mov output_handle, eax
        invoke WriteConsole, output_handle, addr msg_sistema, sizeof msg_sistema, addr count, NULL

        ; Exibindo opcoes (1, 2 ou 3)
        invoke GetStdHandle, STD_OUTPUT_HANDLE 
        mov output_handle, eax
        invoke WriteConsole, output_handle, addr msg_menu_1, sizeof msg_menu_1, addr count, NULL

        invoke GetStdHandle, STD_OUTPUT_HANDLE 
        mov output_handle, eax
        invoke WriteConsole, output_handle, addr msg_menu_2, sizeof msg_menu_2, addr count, NULL

        invoke GetStdHandle, STD_OUTPUT_HANDLE 
        mov output_handle, eax
        invoke WriteConsole, output_handle, addr msg_menu_3, sizeof msg_menu_3, addr count, NULL


        ;------------Informando a opcao
        ;------Handles para a entrada e saída de dados
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov output_handle, eax
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov input_handle, eax

        ;------Exibindo a pergunta e obtendo a resposta do usuário
        invoke StrLen, addr msg_opcao ; pergunta
        mov tamanho_string, eax
        invoke WriteConsole, output_handle, offset msg_opcao, sizeof msg_opcao, offset count, NULL
        invoke ReadConsole, input_handle, offset opcao, sizeof opcao, offset count, NULL

        ;------Realizando a comparacao
        ;--Adicionar Notas
        cmp opcao, 49 ; 49 (ASCII) = 1 (DEC)
        jne exibir_medias ; se nao for igual, vai para a opcao 2 (exibir media)
        
        ;--Incluir aluno e suas 3 notas
        adicionar_notas:
            ;...... Funcionalidades da opcao 1
            invoke GetStdHandle, STD_OUTPUT_HANDLE 
            mov output_handle, eax
            invoke WriteConsole, output_handle, addr op_1_msg, sizeof op_1_msg, addr count, NULL

            ;Compara se o contador de alunos é menor que 40
            cmp qtd_alunos, 40
            jle prosseguir_adicionar ; Se for <= 40, adiciona nome e notas
            
            ; Se não, apresenta a mensagem e volta para o menu de opções
            invoke GetStdHandle, STD_OUTPUT_HANDLE 
            mov output_handle, eax
            invoke WriteConsole, output_handle, addr msg_limite, sizeof msg_limite, addr count, NULL
            jmp menu ; volta para o menu de opcoes

            prosseguir_adicionar: 
                ; informando o nome
                invoke GetStdHandle, STD_OUTPUT_HANDLE
                mov output_handle, eax
                invoke GetStdHandle, STD_INPUT_HANDLE
                mov input_handle, eax

                invoke WriteConsole, output_handle, offset msg_nome, sizeof msg_nome, offset count, NULL
                invoke ReadConsole, input_handle, offset nome_aluno, sizeof nome_aluno, offset count, NULL
                
                ; informando as notas

                ; incrementando o contador de alunos
                xor eax, eax ;zerando eax
                add qtd_alunos, 1
      

        ;--Exibe as medias
        exibir_medias:
            cmp opcao, 50  ; 50 (ASCII) = 2 (DEC)
            jne sair ; se nao for igual, vai para a opcao 3, sair

            ;...... Funcionalidades da opcao 2
            invoke GetStdHandle, STD_OUTPUT_HANDLE 
            mov output_handle, eax
            invoke WriteConsole, output_handle, addr op_2_msg, sizeof op_2_msg, addr count, NULL
            
            ; Exibe o valor de qtd_alunos
            invoke WriteConsole, output_handle, addr msg_qtd_alunos, sizeof msg_qtd_alunos, addr count, NULL ; teste
            printf("%d alunos.\n", qtd_alunos) ;funciona
    
        ;--Encerra o Programa
        sair:
            cmp opcao, 51 ; 51(ASCII) = 3 (DEC)
            jne menu ; se nao for igual, volta para o menu e compara
            
            ;...... Funcionalidades da opcao 3
            invoke GetStdHandle, STD_OUTPUT_HANDLE 
            mov output_handle, eax
            invoke WriteConsole, output_handle, addr op_3_msg, sizeof op_3_msg, addr count, NULL ; Mensagem de agradecimento
        ; encerra
        invoke ExitProcess, 0
end start