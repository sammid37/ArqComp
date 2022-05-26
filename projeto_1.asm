.686
.model flat, stdcall
    option casemap: none

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib
.data
    ; lembrar de converter para ponto flutuante
    soma_notas dd 0 ;soma as notas do aluno
    media_aluno dd 0 ;calcula a media do aluno
    qtd_alunos dd 0 ;contador, armazena a qtd de alunos

    msg_sistema db "BEM-VINDO AO SISTEMA DE NOTAS", 0AH, 0
    msg_menu_1 db "1-Incluir notas de alunos", 0AH, 0
    msg_menu_2 db "2-Exibir médias de alunos", 0AH, 0
    msg_menu_3 db "3-Sair", 13,10, 0AH, 0
    
    msg_opcao db "Digite a opção desejada: ", 0H
    msg_op_select db "A opção escolhida foi %d", 0AH, 0
    msg_limite db "Limite de alunos atingido.", 0AH, 0
    opcao dd 4 dup(0) ; armazena a opção do usuário (resposta para msg_opcao)

    input_handle dd 0
    output_handle dd 0
    tamanho_string dd 0
    count dd 0

.code
start:
    ;------------Mensagem de Bem-vindo
    invoke GetStdHandle, STD_OUTPUT_HANDLE 
    mov output_handle, eax
    invoke WriteConsole, output_handle, addr msg_sistema, sizeof msg_sistema, addr count, NULL

    ; Exibindo opções (1 à 3)
    invoke GetStdHandle, STD_OUTPUT_HANDLE 
    mov output_handle, eax
    invoke WriteConsole, output_handle, addr msg_menu_1, sizeof msg_menu_1, addr count, NULL

    invoke GetStdHandle, STD_OUTPUT_HANDLE 
    mov output_handle, eax
    invoke WriteConsole, output_handle, addr msg_menu_2, sizeof msg_menu_2, addr count, NULL

    invoke GetStdHandle, STD_OUTPUT_HANDLE 
    mov output_handle, eax
    invoke WriteConsole, output_handle, addr msg_menu_3, sizeof msg_menu_3, addr count, NULL


    ;------------Informando a opção

    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov output_handle, eax
    
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov input_handle, eax


    invoke StrLen, addr msg_opcao
    mov tamanho_string, eax
    invoke WriteConsole, output_handle, addr msg_opcao, tamanho_string, addr count, NULL
    invoke ReadConsole, input_handle, addr opcao, sizeof opcao, addr count, NULL

    ;------------ Comparando a opção digitada

    invoke ExitProcess, 0
end start