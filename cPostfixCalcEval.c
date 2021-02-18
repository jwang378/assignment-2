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
  
  

  while (*s != '\0'){
    s = skipws(s);

    int tempDigit = 0;
    if (isDigit(*s)){
      tempDigit ++;
      while(isDigit(*(s+tempDigit))){
        tempDigit++;
      }


    }
  }



  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */
}
