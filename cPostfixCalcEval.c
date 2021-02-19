#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "cPostfixCalc.h"

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
long eval(const char *s) {
  
  long num = 0;
  long stack[20];
  long numNums = 0;
  long*count = &numNums;
  
  
  s = skipws(s);
  while(*s){
    
    
    int currentS = tokenType(s);

    if (currentS == TOK_UNKNOWN){
      fatalError("Unknown value.\n");
    }else{ 
      if (currentS == TOK_INT){
       
        long temp = 0;
        long* tempP = &temp;
        s = consumeInt(s, tempP);
        stackPush(stack, count, temp);
      }else{
        assert(currentS == TOK_OP);

        

        int operator = 0;
        int* op = &operator;
        s = consumeOp(s, op);

        long left, right;

        right = stackPop(stack, count);
        left = stackPop(stack, count);

        num = evalOp(operator, left, right);
        stackPush(stack, count, num);

      }

    }
    s = skipws(s);
  }


  if (*count > 1){
    fatalError("Too many values.");
  }
  num = stackPop(stack, count);

  return num;
  
  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */
  
  
}
