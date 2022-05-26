.686
.model flat, stdcall
    option casemap: none
    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\user32.inc
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\user32.lib
.data
    HelloWorld db "Hello World", 0AH, 0
    msg_handle dd 0
    count dd 0
.code
start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov msg_handle, eax

    ;invoke StrLen, offset HelloWorld
    ;mov tamanho_str, eax ; obtem o tamanho da str registrado em eax

    invoke WriteConsole, msg_handle, addr HelloWorld, sizeof HelloWorld, addr count, NULL

    invoke ExitProcess, 0
end start