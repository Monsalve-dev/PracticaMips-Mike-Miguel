.data
    prompt:   .asciiz "Ingrese el valor de n para Fibonacci (>=0): "
    error:    .asciiz "Error: n debe ser un número entero no negativo.\n"
    result:   .asciiz "El número Fibonacci F("
    result2:  .asciiz ") es: "
    newline:  .asciiz "\n"
    space:    .asciiz " "

.text
    .globl main

main:
    # Mostrar prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Leer entrada de usuario
    li $v0, 5
    syscall
    move $s1, $v0       # Guardar n en $s1
    move $a0, $v0

    # Validar entrada
    blt $s1, $zero, invalid_input

    # Calcular espacio necesario para el arreglo: (n+1)*4 bytes
    addi $t0, $s1, 1      # n+1
    sll $a0, $t0, 2       # (n+1)*4
    li $v0, 9             # Syscall para reservar memoria
    syscall
    move $s2, $v0         # Guardar dirección base del arreglo en $s2

    # Calcular Fibonacci con arreglos
    jal fib_array

    # Mostrar resultado
    li $v0, 4
    la $a0, result
    syscall

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 4
    la $a0, result2
    syscall

    li $v0, 1
    move $a0, $s0         # $s0 contiene el resultado
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # (Opcional) Mostrar secuencia completa
    beq $s1, 0, end      # Saltar si n=0
    li $v0, 4
    la $a0, .sec_msg
    syscall
    
    li $t0, 0            # Contador i
show_loop:
    sll $t1, $t0, 2      # Offset = i*4
    add $t1, $s2, $t1    # Dirección de fib[i]
    lw $a0, 0($t1)       # Cargar fib[i]
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t0, $t0, 1
    ble $t0, $s1, show_loop  # Mostrar desde i=0 hasta i=n

    # Salir
end:
    li $v0, 10
    syscall

invalid_input:
    li $v0, 4
    la $a0, error
    syscall
    j main

fib_array:
    # Manejar casos base
    sw $zero, 0($s2)     # fib[0] = 0
    
    beq $s1, 0, end_fib  # Si n=0, terminar
    
    li $t0, 1
    sw $t0, 4($s2)       # fib[1] = 1
    
    beq $s1, 1, end_fib  # Si n=1, terminar
    
    # Calcular secuencia para i=2 hasta n
    li $t0, 2            # i = 2
loop:
    sll $t1, $t0, 2      # Offset = i*4
    add $t1, $s2, $t1    # Dirección de fib[i]
    
    # fib[i] = fib[i-1] + fib[i-2]
    lw $t2, -4($t1)      # fib[i-1]
    lw $t3, -8($t1)      # fib[i-2]
    add $t4, $t2, $t3
    sw $t4, 0($t1)       # Guardar fib[i]
    
    addi $t0, $t0, 1     # i++
    ble $t0, $s1, loop   # Continuar si i <= n

end_fib:
    # Obtener fib[n]
    sll $t0, $s1, 2      # Offset = n*4
    add $t0, $s2, $t0    # Dirección de fib[n]
    lw $s0, 0($t0)       # Guardar resultado en $s0
    jr $ra

.data
.sec_msg: .asciiz "\nSecuencia completa: "