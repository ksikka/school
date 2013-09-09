#include <stdlib.h>
#include <stdio.h>
 int main() {
   int *a = malloc(sizeof(int) * 100);
   for(int i=0; i < 100; i ++)
   a[i]=i;
   free(a);
 }
