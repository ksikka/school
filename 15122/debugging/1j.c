#include <stdio.h>

int main() {
  int a[50];
  int *i;

  for (i = &a[0]; i < &a[50]; i++) {
    *i = 0;
  }
  return 0;
}
