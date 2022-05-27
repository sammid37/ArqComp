; Samantha Dantas Medeiros (GitHub: @sammid37)
; 27/05/2022
.686
.model flat, stdcall
    option casemap: none

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc
    include \masm32\include\msvcrt.inc
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\msvcrt.lib
    include \masm32\macros\macros.asm
.data
    ; lembrar de converter para ponto flutuante
    soma_notas dd 0 ;soma as notas do aluno
    media_aluno dd 0 ;calcula a media do aluno
    qtd_alunos dd 0 ;contador, armazena a qtd de alunos

    msg_sistema db "BEM-VINDO AO SISTEMA DE NOTAS", 0AH, 0
    msg_menu_1 db "1-Incluir notas de alunos", 0AH, 0
    msg_menu_2 db "2-Exibir medias de alunos", 0AH, 0
    msg_menu_3 db "3-Sair", 13,10, 0AH, 0

    op_1_msg db "Vamos adicionar os alunos e as notas", 0AH, 0
    op_2_msg db "Vamos exibir as medias", 0AH, 0
    op_3_msg db "Obrigado por usar o sistema", 0AH, 0
    
    msg_opcao db "Digite a opcao desejada: ", 0H
    msg_op_select db "A opcao escolhida foi %d", 0AH, 0
    msg_limite db "Limite de alunos atingido.", 0AH, 0
    opcao db 5 dup(0) ; usigned int, armazena a opcao do usuario (resposta para msg_opcao)

    aux_handle dd 0 ; auxiliar de opcao
    input_handle dd 0
    output_handle dd 0
    tamanho_string dd 0
    count dd 0

.code
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


        ;------------Informando a opï¿½ï¿½o
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov output_handle, eax

        invoke GetStdHandle, STD_INPUT_HANDLE
        mov input_handle, eax


        invoke StrLen, addr msg_opcao ; pergunta
        mov tamanho_string, eax
        invoke WriteConsole, output_handle, offset msg_opcao, sizeof msg_opcao, offset count, NULL
        invoke ReadConsole, input_handle, offset opcao, sizeof opcao, offset count, NULL


        ;------Realizando a comparaï¿½ï¿½o
        comparar:
            ;--Adicionar Notas
            cmp opcao, 49
            jne exibir_medias ; se não for igual, vai para a opção 2 (exibir media)

            ;...... Funcionalidades da opï¿½ï¿½o 1
            invoke GetStdHandle, STD_OUTPUT_HANDLE 
            mov output_handle, eax
            invoke WriteConsole, output_handle, addr op_1_msg, sizeof op_1_msg, addr count, NULL

            ;--Exibe as mï¿½dias
            exibir_medias:
                cmp opcao, 50 ; se não for igual, vai para a opção 3 (sair)
                jne sair ; se nï¿½o for igual, vai para a opï¿½ï¿½o 3, sair

                ;...... Funcionalidades da opï¿½ï¿½o 2
                invoke GetStdHandle, STD_OUTPUT_HANDLE 
                mov output_handle, eax
                invoke WriteConsole, output_handle, addr op_2_msg, sizeof op_2_msg, addr count, NULL
       
            ;--Encerra o Programa
            sair:
                cmp opcao, 51
                jne comparar ; se não for igual, volta a comparar
                
                
                ;...... Funcionalidades da opï¿½ï¿½o 3
                invoke GetStdHandle, STD_OUTPUT_HANDLE 
                mov output_handle, eax
                invoke WriteConsole, output_handle, addr op_3_msg, sizeof op_3_msg, addr count, NULL


            invoke ExitProcess, 0
end start