/*
 * postfix calculator (assembly language version)
 * eval function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2

	.section .rodata

eUnknown: .string "Unknown Value"

eTooManyInt: .string "Too many values"


/* TODO: add string constants and other read-only data here */

	.section .text

/*
 * eval - evaluate a postfix expression
 * Should directly or indirectly call fatalError if the expression is invalid.
 *
 * Params:
 *   s - C string containing a postfix expression
 *
 * Returns:
 *   the result of evaluating the expression
 */
	.globl eval
eval:
	pushq %rbp //save frame pointer


	subq $224, %rsp //need 20*8 + a few more 8 bit variables

	/*
	 * 0(%rbp) - num in c, the value to be calculated
	 * 8(%rbp) - numNums in c, the number of numbers we currently have, the address of this will be passed to push and pop
	 * 16 to 176 - long stack[20]
	 * 176(%rbp) - will be used to store s when I need different parameters for other function calls
	 * 184(%rbp) - currentS in c, tokentype of current dereferenced value
	 * 192(%rbp) - temp in c, just a temporary variable to be pushed to stack
	 * 200(%rbp) - operator in c, used to store the value of an operator that has been consumed
	 * 208 and 216 - left and right to store popped values to calculate with evalOp
	 * last 8 for align?
	*/

	call skipws //call skipws using rdi that is still in parameter
	movq %rax, 176(%rbp) //move returned skipws pointer to spot in stack

.LTopOfWhile:

	cmpq $0, (%rdi) //while loop
	jne .LEndOfWhile

	call tokenType //call tokenType since rdi hasn't been changed yet
	movq %rax, 184(%rbp) //move returned value to spot in stack

	cmpq $TOK_UNKNOWN, 184(%rbp) //check current dereferenced value
	je .LUnknownError

	cmpq $TOK_INT, 184(%rbp) //check if it's an int
	je .LDoIntStuff

	cmpq $TOK_OP, 184(%rbp) //check if it's an op
	je .LDoOpStuff

.LDoIntStuff:

	movq $0, 192(%rbp) //create temporary long variable
	movq 176(%rbp), %rdi
	leaq 192(, %rbp, 1), %rsi //move address of temporary long to second parameter
	call consumeInt //call consume int to move consumed int to 192(%rbp)
	movq %rax, 176(%rbp) //update s
	movq 16(%rbp), %rdi //move the stack to first parameter
	leaq (, %rbp, 8), %rsi //move address of numNums into second parameter
	movq 192(%rbp), %rdx //move temp variable to third parameter
	call stackPush //call stack push with the stack, the address of the number of numbers, and the value to be pushed in place

	jmp .LBackToLoop //go back to the while loop

.LDoOpStuff:

	movq $0, 200(%rbp) //move temporary value to operator in stack
	leaq 200(, %rbp, 1), %rsi //move address of temp op to second parameter
	movq 176(%rbp), %rdi //move s to first parameter
	call consumeOp 
	movq %rax, 176(%rbp) //update s

	movq 16(%rbp), %rdi //move stack to rdi
	leaq (, %rbp, 8), %rsi //move address of count to rsi
	call stackPop

	movq %rax, 216(%rbp) //move first pop to right side
	
	movq 16(%rbp), %rdi //move stack to rdi
	leaq (, %rbp, 8), %rsi //move address of count to rsi
	call stackPop

	movq %rax, 208(%rbp) //move second pop to left side

	movq 200(%rbp), %rdi //move operator to first parameter
	movq 208(%rbp), %rsi //move left side to second
	movq 216(%rbp), %rdx //move right to third

	call evalOp //evaluate operation

	movq %rax, 0(%rbp) //update the number

	movq 16(%rbp), %rdi //move stack to rdi
	leaq (, %rbp, 8), %rsi //move address of count to rsi
	movq 0(%rbp), %rdx //move num to third param

	call stackPush //push number back onto stack for next operation

	jmp .LBackToLoop //back to while loop

.LBackToLoop:

	movq 176(%rbp), %rdi 
	call skipws //call skipws after moving s to parameter
	movq %rax, 176(%rbp) //update s
	jmp .LTopOfWhile //to the top of the loop again

.LUnknownError:
	movq $eUnknown, %rdi //move unknown error message to parameter
	call fatalError //call fatal error using error message

.LEndOfWhile: 

	cmpq $1, 8(%rbp) //compare the count of values left on the stack to 1
	jg .LValuesLeft

	jmp .LReturnNum
	
.LValuesLeft:

	movq $eTooManyInt, %rdi //move the error message to parameter
	call fatalError

.LReturnNum:

	movq 16(%rbp), %rdi //move stack to rdi
	leaq (, %rbp, 8), %rsi //move address of count to rsi
	call stackPop

	movq %rax, 0(%rbp) //move returned pop to num

	movq 0(%rbp), %rax //rax is in place but just to be sure

	addq $224, %rsp
	popq %rbp //pop rbp which was pushed earlier
	

	ret

/* vim:ft=gas:
 */
