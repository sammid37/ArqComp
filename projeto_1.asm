; Samantha Dantas Medeiros (GitHub: @sammid37)
; 27/05/2022
.686
.model flat, stdcall
    option casemap: none
    .xmm ; para utilizar as funcoes SSE

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc
    include \masm32\include\msvcrt.inc
    include \masm32\macros\macros.asm
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\msvcrt.lib

.data
    ;------Variaveis referentes ao menu de opcaoes
    ; Mensasagens do Menu
    msg_sistema db "BEM-VINDO AO SISTEMA DE NOTAS", 0AH, 0
    msg_menu_1 db "1-Incluir notas de alunos", 0AH, 0
    msg_menu_2 db "2-Exibir medias de alunos", 0AH, 0
    msg_menu_3 db "3-Sair", 13,10, 0AH, 0
    
    msg_opcao db "Digite a opcao desejada: ", 0H ; unsigned char, pergunta
    opcao db 5 dup(0) ; usigned char, armazena a opcao do usuario (resposta para msg_opcao)
    
    ; Mensagem da opcao escolhida
    op_1_msg db "Vamos adicionar os alunos e as notas", 0AH, 0
    op_2_msg db "Vamos exibir as medias", 0AH, 0
    op_3_msg db "Obrigado por usar o sistema", 0AH, 0
    
    input_handle dd 0 ; handle para a entrada de dados
    output_handle dd 0 ; handle para a sai­da de dados
    tamanho_string dd 0
    count dd 0
    
    ;------Variaveis referentes a opcao 1 
    ; Mensagens (com e sem quebra de linha)
    msg_nome db "Insira o nome do aluno: ", 0H, 0
    msg_nota_1 db "Nota 1: ", 0H, 0
    msg_nota_2 db "Nota 2: ", 0H, 0
    msg_nota_3 db "Nota 3: ", 0H, 0
    msg_limite db "Limite de alunos atingido.", 0AH, 0

    nome_aluno db 15 dup(0) ; armazena o nome do aluno
    nota db 20 dup(0) ; armazena uma nota temporariamente, será convertido para float (8)

    nota_float8 REAL8 0.0 ; nota real 8 temporaria que será passada para os arrays
    
    lista_nomes db 60 dup (0) ;15 * 4 bytes
    n1 REAL8 40 dup(0.0)
    n2 REAL8 40 dup(0.0)
    n3 REAL8 40 dup(0.0)

    msg_digitou db "Digitou: ", 0H, 0
    
    qtd_alunos dd 0, 0 ; contador, armazena a qtd de alunos
    indice_nota dd 0, 0
    indice_aluno dd 0, 0;

    ;------Variaveis referentes a opcao 2
    msg_qtd_alunos db "Quantidade de alunos registrados: ", 0H, 0
    alunos db 15 dup(0) ; sera usado para converter qtd_alunos para string
    quebra_linha db 0, 0AH, 0
    
    ; Array de tamanho 40 preenchido com 0.0
    ; Arrays para as 40 notas 1, 2 e 3 (float, 40 * 8 bytes = 320)
    nota1 REAL4 40 dup(0.0) ; armazena a nota 1
    nota2 REAL4 40 dup(0.0) ; armazena a nota 2
    nota3 REAL4 40 dup(0.0) ; armazena a nota 3  
    
    ; Arrays para as 40 somas de notas e as 40 medias (todoso preenchidos com 0.0)
    qtd_notas dd 3
    soma_notas dd 40 dup(0.0) ; soma as 3 notas de um aluno
    soma_float REAL8 40 dup(0.0)
    media_aluno dd 40 dup(0.0) ; calcula a media do aluno

.code

start:
    xor ebx, ebx ; zerando ebx
    xor eax, eax ; zerando ebx

    ; pilha de exec, inserir notas

    ; pilha de exec, somar notas

    ; pilha de exec, calcular media

    
    
    ;------Handles para a entrada e saida de dados
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov output_handle, eax
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov input_handle, eax
    ;------------Mensagem de Bem-vindo e opcoes
    menu:
        ;--Mensagem de Bem-Vindo
        invoke WriteConsole, output_handle, addr msg_sistema, sizeof msg_sistema, addr count, NULL
        ;--Exibindo opcoes (1, 2 ou 3)   
        invoke WriteConsole, output_handle, addr msg_menu_1, sizeof msg_menu_1, addr count, NULL
        invoke WriteConsole, output_handle, addr msg_menu_2, sizeof msg_menu_2, addr count, NULL
        invoke WriteConsole, output_handle, addr msg_menu_3, sizeof msg_menu_3, addr count, NULL

        ;------------Informando a opcao
        ;------Exibindo a pergunta e obtendo a resposta do usuario
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
            ;......Funcionalidades da opcao 1
            invoke WriteConsole, output_handle, addr op_1_msg, sizeof op_1_msg, addr count, NULL

            ;..Compara se o contador de alunos e menor que 40
            cmp qtd_alunos, 5 ; Para testes, utilize 5
            jl prosseguir_adicionar ; Enquanto for qtd_alunos < 40, adiciona nome e notas
            
            ;..Se nao, apresenta a mensagem e volta para o menu de opcoes
            invoke WriteConsole, output_handle, addr msg_limite, sizeof msg_limite, addr count, NULL
            jmp menu ; volta para o menu de opcoes

            prosseguir_adicionar: 
                ;..Informando o nome
                mov eax, indice_aluno
                invoke WriteConsole, output_handle, offset msg_nome, sizeof msg_nome, offset count, NULL
                invoke ReadConsole, input_handle, offset nome_aluno, sizeof nome_aluno, offset count, NULL
                ;.Adicionar nome ao array de nomes
                ;mov DWORD PTR [lista_nomes+eax], nome_aluno
                ;printf("Nomes: %s\n",lista_nomes[eax])
                
                ;..Informando as notas
                ;.nota 1
                mov ebx, indice_nota
                invoke WriteConsole, output_handle, offset msg_nota_1, sizeof msg_nota_1, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof nota, offset count, NULL   
                invoke StrToFloat, offset nota, addr[n1+ebx] ; Converte a str de nota para float (real8) no array n1       
              
                ;.nota 2
                mov ebx, indice_nota
                invoke WriteConsole, output_handle, offset msg_nota_2, sizeof msg_nota_2, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof nota, offset count, NULL         
                invoke StrToFloat, offset nota, addr[n2+ebx] ; Converte a str de nota para float (real8) no array n2
      
                ;.nota 3
                mov ebx, indice_nota
                invoke WriteConsole, output_handle, offset msg_nota_3, sizeof msg_nota_3, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof n3, offset count, NULL
                invoke StrToFloat, offset nota, addr[n3+ebx] ; Converte a str de nota para float (real8) no array n3
                
                ;..Incrementando o contador de alunos e os indices
                add qtd_alunos, 1
                add indice_aluno, 4 ; +4, pois o array de nome eh do tipo DWORD
                add indice_nota, 8 ; +8, pois os array n1, n2 e n3 sao do tipo REAL8)
                
        ;--Exibe as medias
        exibir_medias:
            cmp opcao, 50  ; 50 (ASCII) = 2 (DEC)
            jne sair ; se nao for igual, vai para a opcao 3, sair

            ;..Mensagem sobre o que a opcao 2 faz e qtd de alunos cadastrados
            invoke WriteConsole, output_handle, addr op_2_msg, sizeof op_2_msg, addr count, NULL
            invoke WriteConsole, output_handle, addr msg_qtd_alunos, sizeof msg_qtd_alunos, addr count, NULL
            invoke dwtoa, qtd_alunos, addr alunos ; converte int para string
            invoke WriteConsole, output_handle, addr alunos, sizeof alunos, addr count, NULL ; qtd de alunos cadastrados
            invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL ; \n
            
            ;..Funcoes SSE
            movups xmm0, OWORD PTR[n1]  
            movups xmm1, OWORD PTR[n2]
            movups xmm2, OWORD PTR[n3]

            addps xmm0, xmm1
            addps xmm0, xmm2

            movups OWORD PTR[soma_notas], xmm0 ; move a soma armazenada em xmm0 para o array soma

            fld DWORD PTR[soma_notas+4]
            fstp QWORD PTR[soma_float]
    
            printf("A soma das notas do aluno 1: %f\n", QWORD PTR[soma_float])


            ; push qtd_alunos ; parÃ¢metro da funÃ§Ã£o calcular_media
            ;call somar_notas
            ;..Impressao de ponto flutuante
            ; invoke FloatToStr, resultado, offset para_imprimir
            
        ;--Encerra o Programa
        sair:
            cmp opcao, 51 ; 51(ASCII) = 3 (DEC)
            jne menu ; se nao for igual, volta para o menu e compara
            
            ;...... Funcionalidades da opcao 3
            invoke WriteConsole, output_handle, addr op_3_msg, sizeof op_3_msg, addr count, NULL ; Mensagem de agradecimento
        ; encerra
        invoke ExitProcess, 0
end start