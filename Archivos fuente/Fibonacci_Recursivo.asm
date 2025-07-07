.data
    prompt:   .asciiz "Ingrese el valor de n para Fibonacci (>=0): "
    error:    .asciiz "Error: n debe ser un número entero no negativo.\n"
    result:   .asciiz "El número Fibonacci F("
    result2:  .asciiz ") es: "
    newline:  .asciiz "\n"

.text
    .globl main

main:
    # Mostrar prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Leer entrada de usuario (n)
    li $v0, 5
    syscall
    move $s1, $v0       # Guardar n en $s1 (valor original para mostrar después)
    move $a0, $v0       # Pasar n como argumento a fib_rec

    # Validar entrada (n >= 0)
    blt $a0, $zero, invalid_input

    # Calcular Fibonacci(n)
    jal fib_rec
    move $s0, $v0       # Guardar resultado en $s0

    # Mostrar resultado CORREGIDO (aquí estaba el error)
    li $v0, 4
    la $a0, result
    syscall

    li $v0, 1
    move $a0, $s1       # Mostrar el n original (input del usuario)
    syscall

    li $v0, 4
    la $a0, result2
    syscall

    li $v0, 1
    move $a0, $s0       # Mostrar el resultado de Fibonacci(n)
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # Salir
    li $v0, 10
    syscall

invalid_input:
    li $v0, 4
    la $a0, error
    syscall
    j main

fib_rec:
    # Casos base
    beq $a0, 0, return0
    beq $a0, 1, return1
    
    # Guardar contexto
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    # fib(n-1)
    addi $a0, $a0, -1
    jal fib_rec
    sw $v0, 8($sp)
    
    # fib(n-2)
    lw $a0, 4($sp)
    addi $a0, $a0, -2
    jal fib_rec
    
    # Sumar resultados
    lw $t0, 8($sp)
    add $v0, $t0, $v0
    
    # Restaurar contexto
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

return0:
    li $v0, 0
    jr $ra

return1:
    li $v0, 1
    jr $ra