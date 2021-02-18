#include <stdio.h>
#include <stdlib.h>
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
  char* s2;
  memcpy(s2, s, strlen(s)+1);

  int firstOp = 0;
  int currentP = 0;

  char* endNum;

  while (*s2 != '\0'){
    if (tokenType(s2)==1){
      firstOp = currentP;
    }
    currentP++;
    s2 = skipws(s2);
    if (isDigit(*s2)){
      if (firstOp < currentP){
        fatalError("Digit after operator.");
        return 1;
      }
      long* temp;
      s2 = consumeInt(s2, temp);
      stackPush(stack, count, temp);
    }
  }


  int first = 0;

  char* ops = s;

  while(*count!= 0){
    long right, left;
    if (first == 0){
      right = stackPop(stack, count);
      left = stackPop(stack, count);

      num = evalOp(*ops, left, right);
    }else{
      right = num;
      left = stackPop(stack, count);
      num = evalOp(*ops, left, right);
    }

    skipws(ops);
    
  }




  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */
  return num;
}
