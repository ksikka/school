#include <stdio.h>
#define MULT(X,Y) (X)*(Y)

int main() {
  int c = MULT(2+3,3+4);
  printf("the result is %d\n",c);
  return 0;
}
