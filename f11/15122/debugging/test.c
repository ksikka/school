#include <stdlib.h>
#include <stdio.h>
#include <string.h>
int main()
{
  int *x;
  int n = 5;
  int i;
  x = malloc(n * sizeof(int));

  for(i = 0; i < n; i++)
  {
    *(x+i) = i+1;
  }
  
  for(i = 0; i < n; i++)
  {
    printf("%d\n", *(x+i));
  }
  
  free(x);
  
  return 0;
}

//*This variable is special
