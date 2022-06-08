; Samantha Dantas Medeiros (GitHub: @sammid37)
; 07/06/2022
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
    msg_sistema db "BEM-VINDO AO SISTEMA DE NOTAS", 0AH
    msg_menu_1 db "1-Incluir notas de alunos", 0AH
    msg_menu_2 db "2-Exibir medias de alunos", 0AH
    msg_menu_3 db "3-Sair", 0AH
    msg_opcao db "Digite a opcao desejada: ", 0H ; unsigned char, pergunta
    opcao db 5 dup(0) ; usigned char, armazena a opcao do usuario (resposta para msg_opcao)
    
    ; Mensagem da opcao escolhida
    op_1_msg db "Vamos adicionar os alunos e as notas", 0AH, 0
    op_2_msg db "Vamos exibir as medias", 0AH, 0
    op_3_msg db "Obrigado por usar o sistema", 0AH, 0

    ; Contadores e Handles
    input_handle dd 0 ; handle para a entrada de dados
    output_handle dd 0 ; handle para a saida de dados
    tamanho_string dd 0
    count dd 0

    ; Contadores essenciais
    alunos db 15 dup(0) ; sera usado para converter qtd_alunos para string
        
    qtd_alunos dd 0 ; contador, armazena a qtd de alunos
    qtd_impressao dd 0 ; contador, sera usado como indice do laco de impresso
    indice_aluno dd 0 ; auxiliar para a insercao de nome em array
    
    ;------Variaveis referentes a opcao 1 
    ; Mensagens (com e sem quebra de linha)
    msg_nome db "Nome do aluno: ", 0H, 0
    msg_nota_1 db "Nota 1: ", 0H
    msg_nota_2 db "Nota 2: ", 0H
    msg_nota_3 db "Nota 3: ", 0H
    msg_media db "MEDIA: ", 0H
    msg_qtd_alunos db "Quantidade de alunos registrados: ", 0H, 0
    msg_limite db "Limite de alunos atingido.", 0AH, 0
    msg_digitou db "Digitou: ", 0H, 0
    quebra_linha db 0, 0AH, 0
    
    ;---- Array de nomes 15 (caracteres para nome) * 40(alunos) bytes
    nome_aluno db 600 dup(0) 
    
    ;--- Armazena uma nota temporariamente, sera convertido para float (8) e inserido nos arrays REAL8 abaixo
    nota db 20 dup(0) 
    
    ;---- Arrays REAL8 de tamanho 40 preenchido com 0.0
    n1 REAL8 40 dup(0.0)
    n2 REAL8 40 dup(0.0)
    n3 REAL8 40 dup(0.0)
    
    ;---- Arrays REAL4 de tamanho 40 preenchido com 0.0
    nota1 REAL4 40 dup(0.0) ; armazena a nota 1
    nota2 REAL4 40 dup(0.0) ; armazena a nota 2
    nota3 REAL4 40 dup(0.0) ; armazena a nota 3  
 
    ;---- Arrays REAL4 para as 40 medias (todoso preenchidos com 0.0)
    qtd_notas REAL4 40 dup(3.0) ; sera usado para dividir a soma das notas (n1+n2+n3)/3
    media REAL4 40 dup(0.0) ; armazena a media das 3 notas de um aluno
    
    ;---- Array REAL8 para as 40 medias calculadas para ser impresso na opcao 2
    media_aluno REAL8 40 dup(0.0) ; para ser impresso 
    
.code
start:
    xor ebx, ebx ; zerando ebx
    xor eax, eax ; zerando eax

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
            cmp qtd_alunos, 40 ; Para testes, utilize 5
            jl prosseguir_adicionar ; Enquanto for qtd_alunos < 40, adiciona nome e notas
            
            ;..Se nao, apresenta a mensagem e volta para o menu de opcoes
            invoke WriteConsole, output_handle, addr msg_limite, sizeof msg_limite, addr count, NULL
            jmp menu ; volta para o menu de opcoes

            prosseguir_adicionar: 
                ;..Informando o nome
                mov eax, qtd_alunos ; 
                mov ebx, 15 ; os 15 caracteres reservados para cada nome foram movidos para ebx
                mul ebx ; eax * ebx, salvo em eax
                add eax, offset nome_aluno
                push eax
                invoke WriteConsole, output_handle, offset msg_nome-1, sizeof msg_nome-1, offset count, NULL
                pop eax
                push eax
                invoke ReadConsole, input_handle, eax, 15, offset count, NULL
                pop eax
                
                ;..Informando as notas
                ; As notas foram inseridas atrav�s da multiplicacao de indice ao inves da soma
                ; Pois eu estava, por algum motivo desconhecido, perdendo todas notas que eu ja havia preenchido (com o metodo da soma de indices)
                ;.nota 1
                mov eax, qtd_alunos
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx ; coloca no topo da pilha
                invoke WriteConsole, output_handle, offset msg_nota_1, sizeof msg_nota_1, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof nota, offset count, NULL
                pop ebx
                push ebx   
                invoke StrToFloat, offset nota, addr[n1+ebx] ; Converte a str de nota para float (real8) no array n1
                mov eax, qtd_alunos
                mov ebx, 4
                mul ebx
                pop ebx ; remove do topo da pilha
                fld REAL8 PTR[n1+ebx] ; carrega o valor do array REAL 8
                fstp REAL4 PTR[nota1+eax] ; preenche o vetor REAL4 com o valor do array REAL 8 
                
                ;.nota 2
                mov eax, qtd_alunos
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx ; coloca no topo da pilha
                invoke WriteConsole, output_handle, offset msg_nota_2, sizeof msg_nota_2, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof nota, offset count, NULL
                pop ebx
                push ebx          
                invoke StrToFloat, offset nota, addr[n2+ebx] ; Converte a str de nota para float (real8) no array n2
                mov eax, qtd_alunos
                mov ebx, 4
                mul ebx
                pop ebx ; remove do topo da pilha
                fld REAL8 PTR[n2+ebx] ; carrega o valor do array REAL 8
                fstp REAL4 PTR[nota2+eax] ; preenche o vetor REAL4 com o valor do array REAL 8
               
                ;.nota 3
                mov eax, qtd_alunos
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx ; coloca no topo da pilha
                invoke WriteConsole, output_handle, offset msg_nota_3, sizeof msg_nota_3, offset count, NULL
                invoke ReadConsole, input_handle, offset nota, sizeof n3, offset count, NULL
                pop ebx
                push ebx
                invoke StrToFloat, offset nota, addr[n3+ebx] ; Converte a str de nota para float (real8) no array n3 
                mov eax, qtd_alunos
                mov ebx, 4
                mul ebx
                pop ebx ; remove do topo da pilha
                fld REAL8 PTR[n3+ebx] ; carrega o valor do array REAL 8
                fstp REAL4 PTR[nota3+eax] ; preenche o vetor REAL4 com o valor do array REAL 8
                               
                ;..Incrementando o contador de alunos e os indices
                add qtd_alunos, 1
                add indice_aluno, 4 ; +4, pois o array de nome eh do tipo DWORD
                jmp menu
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
            
            ;.Garantindo que nao imprima as medias enquanto o contador for igual a zero
            cmp qtd_alunos, 0
            je menu ; se for igual a zero, nao continua
            
            ;..Empilhando o parametro e chamando a funcao para Calcular as Medias
            push qtd_alunos
            call calcular_media
            
            ;..Impressao: 
            loop_impressao:
            ;.Exibe o nome do aluno
                mov eax, qtd_impressao
                mov ebx, 15 ; tamanho maximo para um nome
                mul ebx ; 15 * indice do aluno
                add eax, offset nome_aluno ; vetor
                push eax
                invoke StrLen, eax
                mov tamanho_string, eax
                pop eax
                ;invoke WriteConsole, output_handle, offset msg_nome, sizeof msg_nome, offset count, NULL
                invoke WriteConsole, output_handle, eax, tamanho_string, offset count, NULL
            ;.Exibe as 3 notas do aluno
                ;.n1, fazendo conversao de float para string
                mov eax, qtd_impressao
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx
                invoke FloatToStr, [n1+ebx], offset nota
                invoke StrLen, offset nota
                mov tamanho_string, eax
                invoke WriteConsole, output_handle, offset msg_nota_1, sizeof msg_nota_1, offset count, NULL
                invoke WriteConsole, output_handle, addr nota, tamanho_string, addr count, NULL ; n1 em str
                invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL ; quebra de linha
                pop ebx
                
                ;.n2, fazendo conversao de float para string
                mov eax, qtd_impressao
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx
                invoke FloatToStr, [n2+ebx], offset nota
                invoke StrLen, offset nota
                mov tamanho_string, eax
                invoke WriteConsole, output_handle, offset msg_nota_2, sizeof msg_nota_2, offset count, NULL
                invoke WriteConsole, output_handle, addr nota, tamanho_string, addr count, NULL ; n2 em str
                invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL ; quebra de linha
                pop ebx
                
                ;.n3, fazendo conversao de float para string
                mov eax, qtd_impressao
                mov ebx, 8
                mul ebx
                mov ebx, eax
                push ebx
                invoke FloatToStr, [n3+ebx], offset nota
                invoke StrLen, offset nota
                mov tamanho_string, eax
                invoke WriteConsole, output_handle, offset msg_nota_3, sizeof msg_nota_3, offset count, NULL
                invoke WriteConsole, output_handle, addr nota, tamanho_string, addr count, NULL ; n3 em str
                invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL ; quebra de linha
                pop ebx

                ;.Exibe a media do aluno
                mov eax, qtd_impressao
                mov ebx, 4
                mul ebx
                mov ebx, eax
                push ebx
                mov eax, qtd_impressao
                mov ecx, 8
                mul ecx
                mov ecx, eax
                push ecx
                ;.Carrega o conteudo do array REAL4 para o array REAL8 para relizar a impressao
                fld DWORD PTR[media+ebx]
                fstp QWORD PTR[media_aluno+ecx]
                ;.Converte Float para String no tamanho da variavel nota (aquela usada na opcao 1)
                invoke FloatToStr, [media_aluno+ecx], offset nota
                invoke StrLen, offset nota
                mov tamanho_string, eax
                ;.Imprimindo a media :D
                invoke WriteConsole, output_handle, offset msg_media, sizeof msg_media, offset count, NULL
                invoke WriteConsole, output_handle, addr nota, tamanho_string, offset count, NULL
                invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL 
                invoke WriteConsole, output_handle, addr quebra_linha, sizeof quebra_linha, addr count, NULL ; quebra de linha de novo, estica, ultima nota
                ;invoke WriteConsole, output_handle, addr media_aluno, sizeof media_aluno, addr count, NULL
                pop ebx
                pop ecx

                ;..Incrementa o contador de impressoes e compara com o valor de alunos cadastrados
                add qtd_impressao, 1
                mov ecx, qtd_alunos
                cmp qtd_impressao, ecx
                jne loop_impressao ; se a qtd de impressoes nao for igual a quantidade de alunos cadastrados, retorna para o inicio do loop
                mov qtd_impressao, 0  ; se for igual, zera o contador e volta para o menu
                jmp menu 
            
            
            ;....Funcoes SSE
            ;..Funcao que calcula a media
            calcular_media:
                ;..Empilhando
                ; [EBP+8]: parametro qtd_alunos (contador de alunos cadastrados no sistema)
                ; [EBP+4]: endereco de retorno
                ; [EBP]
                ; Variaveis locais da pilha:
                ; [EBP-4]: indice de incremento do laco (como o i do laco for)
                ; [EBP-8]: limite de incrementos
                push ebp ; colando no topo da pilha o valor de ebp, como backup
                mov ebp, esp ; movendo para o novo ebp o valor de esp
                sub esp, 8 ; realizando o deslocamento de 8 bytes (de duas variaveis locais do tipo DWORD/dd)
                
                ;..Inicializando variaveis locais
                ;.Zerando o contador de iteracoes (ebp-8) e edx
                mov DWORD PTR[ebp-8], 0 
                xor edx, edx 
                mov ebx, 4 ; operacao do calculo de 4 em 4 notas                 
                mov eax, DWORD PTR[ebp+8] ; move para eax o valor do parametro qtd_alunos
                div ebx ; divide o valor da qtd de alunos por 4, resultado armazenado em EAX e o resto em EDX
                cmp edx, 0 ; compara se o resto da divisao eh igual a zero
                jne incrementar ; se nao for igual, pula para incrementar
                jmp prosseguir_calculo; se for igual, pula para prosseguir_calculo

                ;.Caso o resto for diferente que zero
                incrementar: 
                    add eax, 1 ; incrementando o resultado da divisao, ou seja, a quantidade maxima de iteracoes
                    mov DWORD PTR[ebp-4], eax ; move para 
                    
                ;..Prosseguindo com o calculo, armazenados notas em registradores em xmm e preenchendo o array media (REAL4)
                prosseguir_calculo:
                    mov eax, DWORD PTR[ebp-8]
                    mov ebx, 16 ; referente as 4 notas de 4 bytes do array real4
                    mul ebx
                    
                    ;..Adicionando o conteudo dos arrays para os registradores xmm
                    ;.Nota1 (REAL4)
                    push eax ; empilhando o valor de eax
                    add eax, offset nota1 ; passando o tamanho do array REAL4 para eax
                    movups xmm0, OWORD PTR[eax]
                    pop eax 
                    ;.Nota2 (REAL4)
                    push eax ; empilhando o valor de eax
                    add eax, offset nota2 ; passando o tamanho do array REAL4 para eax
                    movups xmm1, OWORD PTR[eax]
                    pop eax 
                    ;.Nota1 (REAL4)
                    push eax ; empilhando o valor de eax
                    add eax, offset nota3 ; passando o tamanho do array REAL4 para eax
                    movups xmm2, OWORD PTR[eax]
                    pop eax 
                    ;.Quantidade de notas (3.0)
                    movups xmm3, OWORD PTR[qtd_notas] ; array preenchido com 3.0
                    ;..Somando as notas
                    addps xmm0, xmm1
                    addps xmm0, xmm2
                    ;..Dividindo as notas (aka calculando a media)
                    divps xmm0, xmm3
                    ;..Passando o conteudo do registrador xmm3 para o array REAL4
                    add eax, offset media
                    movups OWORD PTR[eax], xmm0
                    add DWORD PTR[ebp-8], 1 ; incrementando 
                    mov eax, DWORD PTR[ebp-8]
                    ;..Comparando se a iterecao bateu com o limite maximo de iteracoes
                    cmp DWORD PTR[ebp-4], eax
                    jne prosseguir_calculo ; se nao for igual, volta para prosseguir calculo, ou seja, garante que todas as notas tenham sido preenchidas
               ;....DESEMPILHANDO
               mov esp, ebp
               pop ebp
               ret 4 ; quantidade de bytes do parametro qtd_alunos
 
        ;--Encerra o Programa
        sair:
            cmp opcao, 51 ; 51(ASCII) = 3 (DEC)
            jne menu ; se nao for igual, volta para o menu e compara
            jmp encerrar ; se for igual, vai direto para o opcao de encerramento (ExitProcess)
            
            
        encerrar:
            ;...... Funcionalidades da opcao 3
            invoke WriteConsole, output_handle, addr op_3_msg, sizeof op_3_msg, addr count, NULL ; Mensagem de agradecimento
            invoke ExitProcess, 0
end start