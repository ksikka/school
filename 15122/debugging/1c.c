#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {
  char *w = malloc(sizeof("C Programming"));
  char *x = "C Programming";
  strcpy(w,x);
  printf("%s\n", w);
  return 0;
}
