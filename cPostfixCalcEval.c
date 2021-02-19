#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
  const char* s2;
  //memcpy(s2, s, strlen(s)+1);
  s2 = s;

  int firstOp = 0;
  
  const char* ops = s;

  while (*s2 != '\0'){

    s2 = skipws(s2);
    if (tokenType(s2)==2){
      fatalError("Unknown value.\n");
    }
    if (tokenType(s2)==1 && firstOp == 0){
      ops = s2;
      firstOp ++;    
    }
    
    
    if (isDigit(*s2)){
      if (firstOp != 0){
        fatalError("Digit after operator.\n");
      }

      long tempVal;
      long* temp = & tempVal;
      s2 = consumeInt(s2, temp);
      stackPush(stack, count, *temp);
    }
    
    s2++;
  }



  if (*count <= 1){
    if (tokenType(ops) == 1){
      if (numNums == 1){
        fatalError("Too many operators.\n");
      }else{
        fatalError("Something has gone horribly wrong.\n");
      }
    }
  }
  
  
  while(*count > 1){
    ops = skipws(ops);  
    long right, left;
    right = stackPop(stack, count);
    left = stackPop(stack, count);
    num = evalOp(*ops, left, right);
    stackPush(stack, count, num);
    ops++;
    
  }

  num = stackPop(stack, count);

  if (numNums > 0){
    fatalError("Too many values left in stack.\n");
  }






  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */
  
  return num;
}
