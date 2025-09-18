; fibonacci.s
; Programa en ensamblador para STM32F103C8 (Cortex-M3, Thumb)
; Calculó la secuencia Fibonacci Fn para n en 0..47 y guardó los resultados en SRAM (hex).
; Los resultados se almacenaron como words (32 bits) empezando en fib_space.

    AREA |.text|, CODE, READONLY
    THUMB
    EXPORT __main
    ENTRY

__main
    ; --- Cargar n desde la sección .data ---
    LDR     R0, =n_value      ; R0 <- dirección de n_value
    LDR     R0, [R0]          ; R0 <- n

    ; --- Limitar n a 47 (por requerimiento) ---
    CMP     R0, #47
    BLE     ok_n
    MOV     R0, #47
ok_n

    ; --- Preparar puntero de destino en SRAM ---
    LDR     R1, =fib_space    ; R1 <- dirección base donde se guardó la secuencia

    ; --- Inicializar F0 = 0, F1 = 1 y contador ---
    MOV     R2, #0            ; R2 = F0
    MOV     R3, #1            ; R3 = F1

    ; --- Caso n = 0: almacenar solo F0 y terminar ---
    CMP     R0, #0
    BEQ     store_f0_done

    ; --- Caso general: almacenar F0 ---
    STR     R2, [R1], #4      ; store F0, R1 += 4

    ; --- Almacenar F1 si n >= 1 ---
    STR     R3, [R1], #4      ; store F1, R1 += 4

    ; --- Si n == 1 ya habíamos almacenado los dos primeros, terminar ---
    CMP     R0, #1
    BEQ     done

    ; --- Bucle: i = 2 .. n   (calcula Fn = F0 + F1) ---
    MOV     R4, #2            ; R4 = i (contador)
loop_calc
    ADDS    R5, R2, R3        ; R5 = F0 + F1 (próximo término) (use ADDS para flags si se necesitara)
    STR     R5, [R1], #4      ; almacenar próximo término, R1 += 4

    ; rotar valores: F0 <- F1 ; F1 <- R5
    MOV     R2, R3
    MOV     R3, R5

    ADDS    R4, R4, #1        ; i++
    CMP     R4, R0
    BLE     loop_calc

    B       done

store_f0_done
    STR     R2, [R1], #4      ; almacenar F0 (0)
    B       done

done
    ; Aquí quedó el programa (buena práctica: bucle infinito)
endloop
    B       endloop

    ; -------------------- Datos --------------------
    AREA |.data|, DATA, READWRITE
n_value
    DCD     5                 ; <- CAMBIE ESTE VALOR POR MI N

    ; Reservé espacio en SRAM para almacenar hasta 48 palabras (0..47 inclusive)
    AREA |.bss|, NOINIT, READWRITE
fib_space
    SPACE   192               ; 48 * 4 bytes = 192 bytes

    END
