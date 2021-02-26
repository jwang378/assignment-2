/*
 * postfix calculator (assembly language version)
 * function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2

.equ MAX_STACK, 20

	.section .rodata

eNegativeValue: .string "Negative value"

/* TODO: add other string constants and other read-only data here */

	.section .text

/*
 * addPositive function (this is just an example function)
 */
	.globl addPositive
addPositive:
	subq $8, %rsp                /* align stack pointer */

	movq $0, %r10                /* let %r10 be 0 */
	cmpq %rdi, %r10              /* compare 1st param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */
	cmpq %rsi, %r10              /* compare 2nd param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */

	/* both operands are non-negative, do the addition */
	movq %rsi, %rax              /* move second parameter to %rax */
	addq %rdi, %rax              /* add first parameter to second */
	jmp .LaddPositiveDone

.LaddPositiveNegativeOperand:
	movq $eNegativeValue, %rdi
	call fatalError
9:	jmp 9b                       /* should not get here */

.LaddPositiveDone:
	/* the sum is now in %rax */
	addq $8, %rsp                /* restore stack pointer */
	ret

/*
 * fatalError - print an error message an exit with an exit code of 1.
 * Prints a message of the form "Error: <message text>" to standard output.
 * Does not return!
 *
 * Params:
 *   msg - description of the error which occurred
 */
	.globl fatalError
fatalError:
	
	/* note that this function should not return */

	subq $8, %rsp //stack align
	call printf //calls printf, should be called by another function that has already moved the message to rdi
	
	movq $1, %rdi //move 1 to first parameter

	addq $8, %rsp //stack align
	call exit //exit with 1
	ret

/*
 * isSpace - tests a character code to determine whether or not it
 * is a space character.
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a space or tab character, 0 otherwise
 *   (the function is allowed to also return 1 if c is a newline
 *   or carriage return, but it's only required to handle
 *   spaces and tabs)
 */
	.globl isSpace
isSpace:
	subq $8, %rsp //stack align
	movq $9, %r10 //move 9 to r10
	movq $32, %r11 //move 32 to r11
	//9 and 32 are space values so these are needed to compare
	cmpq %rdi, %r10 //compare parameter and r10
	je .LIsZero //if it's space, return

	cmpq %rdi, %r11 //compare parameter and r10
	je .LIsZero // if it's space, return
	
	jmp .LIsNotZero //hits this if comparison fails
	
.LIsZero:
	movq $1, %rax //because it's a space we move 1 to rax to return
	jmp .LReturnCompareSpace //return because assignment is finished
	
.LIsNotZero:
	movq $0, %rax //not a space so we move 0 to rax to return
	jmp .LReturnCompareSpace //return because assignment is finished
	
.LReturnCompareSpace:
	addq $8, %rsp //stack align
	ret

/*
 * isDigit - tests a character code to determine whether it is one
 * of the digits '0' through '9'
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a digit, 0 otherwise
 */
	.globl isDigit
isDigit:

	subq $8, %rsp //stack align
	movq $48, %r10 //move the first digit ascii value to r10

.Ltop:
	cmpq %r10, %rdi //compare digit and input
	je .LIsDigit //if digit jump to digit
	addq $1, %r10 //increment ascii value by 1 for compared digits
	cmpq $58, %r10 //compare to 57, the last digit
	je .LIsNotDigit //if 58 then not digit
	jmp .Ltop //back to beginning of loop

.LIsDigit:
	movq $1, %rax //put 1 in return
	jmp .LReturnCompareDigit//return

.LIsNotDigit:
	movq $0, %rax //put 0 in return
	jmp .LReturnCompareDigit//return

.LReturnCompareDigit:	
	addq $8, %rsp //stack align
	ret

/*
 * skipws - skips any whitespace characters (as determined by isSpace)
 * at the beginning of a C character string.
 *
 * Params:
 *   s - pointer to a C character string
 *
 * Returns:
 *   pointer to the first non-space character in the string, or NULL
 *   if there are no non-space characters before the end of the string
 *   is reached
 */
	.globl skipws
skipws:
	
	subq $8, %rsp //stack align

	movq $0, %r10 //null to r10
	movq %rdi, %r11 //move parameter to 11

.LSkipWSLoop:
	cmpq %r11, %r10 //compare pointer and null
	je .LWhiteSpaceStringNull //if null pointer, jump to null return

	movq (%r11), %r8 //move dereferenced pointer value to r8
	movq %r8, %rdi //move r8 value to rdi so it can be used as a parameter

	call isSpace //call isspace to see if dereferenced pointer is a space
	cmpq $1, %rax //compare returned value and 1 to see if it's a space
	jne .LSpacesSkipped //value is not a space so spaces have been skipped
	
	addq $1, %r11 //increment pointer by 1

	jmp .LSkipWSLoop //back to top of loop
.LWhiteSpaceStringNull:
	movq 0, %rax//return null
	jmp .LReturnSkipws //return

.LSpacesSkipped:
	movq %r11, %rax //return pointer to non space char
	jmp .LReturnSkipws

.LReturnSkipws:
	addq $8, %rsp //stack align
	ret

/*
 * tokenType - return the token type (TOK_INT, TOK_OP, or TOK_UNKNOWN)
 * of the token at the beginning of given C character string.
 *
 * Params:
 *   s - nonempty C character string (which should not have any leading
 *       space characters)
 *
 * Returns:
 *   the token type
 */
	.globl tokenType
tokenType:
	/* TODO: implement */
	ret

/*
 * consumeInt - consume one or more digit characters at the beginning
 * of given C character string, convert them to an integer value, and
 * store the integer value in the long (64 bit signed integer)
 * variable that pval points to.
 *
 * Params:
 *   s    - pointer to a nonempty C character string which should start
 *          with a digit character
 *   pval - points to a long variable where the converted integer value
 *          should be stored
 *
 * Returns:
 *   pointer to the first character in the string that is not a digit
 */
	.globl consumeInt
consumeInt:
	/* TODO: implement */
	ret

/*
 * consumeOp - consume an operator character from the beginning of the
 * given C character string.
 *
 * Params:
 *   s - pointer to a nonempty C character string
 *   op - pointer to an int (32 bit signed integer) variable where the
 *        ASCII code of the first character of s should be stored
 *
 * Returns:
 *   a pointer to the second character of s
 */
	.globl consumeOp
consumeOp:
	/* TODO: implement */
	ret

/*
 * stackPush - push a long (64 bit signed integer) value onto the stack.
 * Calls the fatalError function if the stack is full.
 * A full stack contains MAX_STACK (20) values.
 * If a value is successfully pushed on the stack, the count should
 * be incremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *   val   - the value to push onto the stack
 *
 * Returns:
 *   nothing
 */
	.globl stackPush
stackPush:
	/* TODO: implement */
	ret

/*
 * stackPop - pops a long (64 bit signed integer) value from the stack.
 * Calls the fatalError function if the stack is empty.
 * If a value is successfully popped off the stack, the count should
 * be decremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *
 * Returns:
 *   the value popped from the stack
 */
	.globl stackPop
stackPop:
	/* TODO: implement */
	ret

/*
 * evalOp - evaluate a computation by applying an operator to two operands.
 *
 * Params:
 *   op - the operator ('+', '-', '*', or '/')
 *   left - the left operand
 *   right - the right operand
 *
 * Returns:
 *   the result of applying the operator to the operands
 */
	.globl evalOp
evalOp:
	ret

/* vim:ft=gas:
 */
