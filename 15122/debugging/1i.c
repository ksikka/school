#include <stdio.h>
#include <stdlib.h>

int main() {
  int a[] = {1,1,2,3,5,8,13,21,34,55};
  printf("%d\n", *(a+2)+*(a+5));
  return 0;
}
